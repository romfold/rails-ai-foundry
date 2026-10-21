# frozen_string_literal: true

module Conversations
  class DemoProvider
    def call(question:, history:, &block)
      "Offline demo reply #{history.size + 1}: #{question}".scan(/.{1,12}/m).each(&block)
    end
  end
end
