# frozen_string_literal: true

module Directory
  class Schema < GraphQL::Schema
    use GraphQL::Dataloader
    query QueryType
    max_depth 5
    max_complexity 200
  end
end
