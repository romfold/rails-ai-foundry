# frozen_string_literal: true

require 'digest'

module Knowledge
  class Ingest
    class StaleSource < StandardError; end
    class SourceConflict < StandardError; end

    def initialize(embedder: DemoEmbeddings.new, version: DemoEmbeddings::VERSION)
      @embedder = embedder
      @version = version
    end

    def call(tenant_id:, title:, body:, source_key: nil)
      source_key ||= Digest::SHA256.hexdigest(JSON.generate([title, body]))
      Telemetry.measure('ingest') do
        passages = build_passages(body)
        persist(tenant_id, source_key, title, body, passages)
      end
    end

    def reembed(tenant_id:, id:)
      Telemetry.measure('reembed') do
        document = Document.find_by!(tenant_id: tenant_id, id: id)
        revision = document.lock_version
        passages = build_passages(document.body)
        document.with_lock do
          if revision != document.lock_version
            raise StaleSource, 'Source changed during embedding; retry from its current revision.'
          end

          replace_passages(document, passages)
        end
        Telemetry.indexed(document)
      end
    end

    private

    def persist(tenant_id, source_key, title, body, passages)
      document = Document.transaction do
        record = Document.create_or_find_by!(tenant_id: tenant_id, source_key: source_key) do |candidate|
          candidate.title = title
          candidate.body = body
        end
        record.with_lock do
          unless record.title == title && record.body == body
            raise SourceConflict, 'Source key already belongs to different content.'
          end

          replace_passages(record, passages)
        end
        record
      end
      Telemetry.indexed(document)
      document
    end

    def replace_passages(document, passages)
      Passage.where(document_id: document.id, version: @version).delete_all
      save_passages(document, passages)
    end

    def build_passages(body)
      body.split(/\n\s*\n/).reject(&:blank?).map do |text|
        values = @embedder.call(text)
        Vector.encode(values)
        { body: text, embedding: values }
      end
    end

    def save_passages(document, passages)
      passages.each_with_index do |passage, ordinal|
        Passage.create!(**passage, document_id: document.id, document_revision: document.lock_version,
                                   version: @version, ordinal: ordinal)
      end
    end
  end
end
