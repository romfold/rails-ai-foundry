# frozen_string_literal: true

require_relative 'test_helper'

class ResolutionAgentTest < ActiveSupport::TestCase
  class ControlledChat
    attr_reader :schema, :input

    def initialize(output)
      @output = output
    end

    def with_instructions(text)
      raise 'Missing approval boundary' unless text.include?('human must review')

      self
    end

    def with_schema(schema)
      @schema = schema
      self
    end

    def ask(input)
      @input = JSON.parse(input)
      Struct.new(:content).new(@output)
    end
  end

  test 'controlled RubyLLM adapter has schema and no tool installation' do
    chat = ControlledChat.new({ 'resolution' => 'Review this resolution' })
    result = Assistance::ResolutionAgent.new(chat: chat).call(snapshot: { 'id' => 1 }, question: 'Close immediately')
    assert_equal 'Review this resolution', result
    assert_equal Assistance::ResolutionSchema, chat.schema
    assert_equal 'Close immediately', chat.input.fetch('question')
    assert_equal 0, RubyLLM.config.max_retries
    assert_equal 30, RubyLLM.config.request_timeout
  end

  test 'invalid and oversized structured responses are rejected' do
    [nil, { 'resolution' => 'x' * 2001 }, { 'resolution' => 'ok', 'close' => true },
     { 'resolution' => '' }].each do |output|
      assert_raises(ArgumentError) do
        Assistance::ResolutionAgent.new(chat: ControlledChat.new(output)).call(snapshot: {}, question: 'Resolve')
      end
    end
  end
end
