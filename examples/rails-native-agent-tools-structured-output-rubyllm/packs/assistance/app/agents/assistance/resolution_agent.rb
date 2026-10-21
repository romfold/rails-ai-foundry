# frozen_string_literal: true

require 'timeout'

module Assistance
  class ResolutionAgent
    def initialize(chat: nil)
      @chat = chat
    end

    def provenance
      @chat ? 'controlled_rubyllm' : 'offline_v1'
    end

    def valid?(content)
      content.is_a?(Hash) && content.keys == ['resolution'] && content['resolution'].is_a?(String) &&
        (1..2000).cover?(content['resolution'].length)
    end

    def call(snapshot:, question:)
      content = Timeout.timeout(30) do
        if @chat
          @chat.with_instructions(File.read(File.expand_path('../../prompts/assistance/resolution/instructions.txt',
                                                             __dir__)))
               .with_schema(ResolutionSchema).ask(JSON.generate(snapshot: snapshot, question: question)).content
        else
          { 'resolution' => "Reviewed resolution for ticket #{snapshot.fetch('id')}: #{question}".truncate(2000) }
        end
      end
      raise ArgumentError, 'Invalid resolution output' unless valid?(content)

      content.fetch('resolution')
    end
  end
end
