# frozen_string_literal: true

require 'async'

module Directory
  class Schema < GraphQL::Schema
    use GraphQL::Dataloader::AsyncDataloader
    query QueryType
    max_depth 5
    max_complexity 200
  end
end
