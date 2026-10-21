# frozen_string_literal: true

module Directory
  class QueryType < GraphQL::Schema::Object
    field :people, [PersonType, { null: true }], null: false do
      argument :ids, [ID], required: true
    end

    def people(ids:)
      raise GraphQL::ExecutionError, 'At most 100 people per request' if ids.size > 100

      dataloader.with(PeopleSource, context.fetch(:tenant), context.fetch(:role)).load_all(ids)
    end
  end
end
