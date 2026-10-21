# frozen_string_literal: true

module Knowledge
  module Commands
    class ChangeDocument < Dry::Operation
      skip_prepending

      def initialize(database:, queue:)
        super()
        @database = database
        @queue = queue
      end

      def call(principal:, action:, id: nil, attributes: {}, **options)
        result = nil
        @database.gate do
          result = steps do
            document = step(resolve(principal, action, id, options[:expected_revision], attributes))
            persist(document, action, attributes)
            record_intent(document)
            step(options.fetch(:after_write, -> {}).call || Success())
            document
          end
          raise Sequel::Rollback if result.failure?
        end
        result
      end

      private

      def record_intent(document)
        @database.record_change(document)
        @queue.enqueue(event_id: SecureRandom.uuid, target: 'res', payload: event(document))
      end

      def resolve(principal, action, id, revision, attributes)
        return create_document(principal, attributes) if action == 'create'

        document = @database.documents.where(id: id, tenant_id: principal.tenant_id).for_update.first
        error = DocumentPolicy.error(document, action, revision, attributes)
        error ? Failure(error) : Success(document)
      end

      def create_document(principal, attributes)
        return Failure(:invalid_content) unless DocumentPolicy.valid_content?(attributes)

        Success({ id: SecureRandom.uuid, tenant_id: principal.tenant_id, revision: 0,
                  status: 'draft', created_at: Time.now.utc }.merge(attributes.slice(:title, :body)))
      end

      def persist(document, action, attributes)
        document[:revision] += 1
        document[:updated_at] = Time.now.utc
        case action
        when 'create' then @database.documents.insert(document)
        when 'edit' then update(document, attributes.slice(:title, :body).merge(status: 'draft'))
        when 'publish' then update(document, status: 'published')
        when 'withdraw' then update(document, status: 'withdrawn')
        when 'delete' then update(document, status: 'deleted', title: '', body: '')
        end
      end

      def update(document, attributes)
        document.merge!(attributes)
        @database.documents.where(id: document.fetch(:id)).update(document.except(:id))
      end

      def event(document)
        { 'schema' => 1, 'document_id' => document.fetch(:id), 'tenant_id' => document.fetch(:tenant_id),
          'revision' => document.fetch(:revision) }
      end
    end
  end
end
