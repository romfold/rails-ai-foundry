# frozen_string_literal: true

module Knowledge
  class ChangeDocument < Dry::Operation
    skip_prepending

    def call(principal:, action:, id: nil, attributes: {}, **options)
      result = nil
      Document.transaction(requires_new: true) do
        result = steps do
          row = step(resolve(principal, action, id, attributes, options[:expected_revision]))
          mutate(row, action, attributes)
          step(options.fetch(:after_write, -> {}).call || Success())
          row.attributes.symbolize_keys
        end
        raise ActiveRecord::Rollback if result.failure?
      end
      result
    end

    private

    def resolve(principal, action, id, attributes, revision)
      return create(principal, attributes) if action == 'create'

      row = Document.where(id: id, tenant_id: principal.tenant_id).lock.first
      error = DocumentPolicy.error(row&.attributes&.symbolize_keys, action, revision, attributes)
      error ? Failure(error) : Success(row)
    end

    def create(principal, attributes)
      return Failure(:invalid_content) unless DocumentPolicy.valid_content?(attributes)

      Success(Document.new(attributes.slice(:title, :body).merge(id: SecureRandom.uuid,
                                                                 tenant_id: principal.tenant_id, revision: 0)))
    end

    def mutate(row, action, attributes)
      case action
      when 'edit' then row.assign_attributes(attributes.slice(:title, :body).merge(status: 'draft'))
      when 'publish' then row.status = 'published'
      when 'withdraw' then row.status = 'withdrawn'
      when 'delete' then row.assign_attributes(status: 'deleted', title: '', body: '')
      end
      row.revision += 1
      row.save!
    end
  end
end
