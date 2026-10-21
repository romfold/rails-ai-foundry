# frozen_string_literal: true

module Knowledge
  class Embedding < ActiveRecord::Base
    self.table_name = 'embeddings'
  end
end
