# frozen_string_literal: true

module Knowledge
  class Database
    def initialize(url)
      @url = url
    end

    def rom
      @rom ||= ROM.container(:sql, @url, after_connect: lambda { |connection|
        connection.exec("SET statement_timeout = '2s'")
        connection.exec("SET lock_timeout = '2s'")
      })
    end

    def connection
      rom.gateways[:default].connection.tap { |connection| connection.timezone = :utc }
    end

    def documents
      connection[:knowledge_documents]
    end

    def gate
      rom.gateways[:default].transaction(savepoint: true) do
        connection.run("SET LOCAL statement_timeout = '2s'")
        connection.run("SET LOCAL lock_timeout = '2s'")
        connection.fetch('SELECT pg_advisory_xact_lock(?)', 817_264).all
        yield
      end
    end

    def record_change(document)
      journal = connection[:knowledge_projection_changes]
      journal.insert(previous_id: journal.max(:id) || 0, document_id: document.fetch(:id),
                     revision: document.fetch(:revision),
                     status: document.fetch(:status), created_at: Time.now.utc)
    end

    def disconnect
      @rom&.disconnect
    end
  end
end
