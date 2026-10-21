# frozen_string_literal: true

module Directory
  class PersonType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :name, String, null: false
    field :manager, PersonType

    def manager
      dataloader.with(PeopleSource, context.fetch(:tenant), context.fetch(:role)).load(object.manager_id)
    end
  end
end
