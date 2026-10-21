# frozen_string_literal: true

require_relative 'ticket_lookup'

module SupportDesk
  class Conversation
    attr_reader :state

    def initialize(llm:, tool:, history: [])
      @tool = tool
      instructions = File.read(File.expand_path('../prompts/support.txt', __dir__))
      @assistant = Langchain::Assistant.new(llm: llm, tools: [tool], parallel_tool_calls: false,
                                            instructions: instructions)
      restore_history(history)
      @state = :ready
    end

    def ask(text)
      raise ArgumentError, 'Start a new conversation after failed processing' if @state == :failed

      validate_message(text)

      @remaining_calls = 6
      @state = :running
      @assistant.add_message(content: text)
      run_provider
      while @assistant.state == :requires_action
        execute_tools
        run_provider
      end
      raise IOError, 'Assistant did not complete' unless @assistant.state == :completed

      @state = :completed
      @assistant.messages.last.content
    rescue StandardError
      @state = :failed
      raise
    end

    def history
      snapshot = @assistant.messages.reject(&:system?).map do |message|
        { role: message.role, content: message.content, tool_calls: message.tool_calls,
          tool_call_id: message.tool_call_id }
      end
      JSON.parse(JSON.generate(snapshot))
    end

    private

    def validate_message(text)
      return if text.is_a?(String) && (1..2000).cover?(text.size)

      raise ArgumentError, 'Message must contain 1..2000 characters'
    end

    def restore_history(history)
      history.each do |message|
        unless %w[user assistant tool].include?(message.fetch('role'))
          raise ArgumentError, 'Restore only application-owned user, assistant and tool history'
        end

        @assistant.add_messages(messages: [message.transform_keys(&:to_sym)])
      end
    end

    def run_provider
      attempts = 0
      begin
        raise IOError, 'Conversation request budget exhausted' unless @remaining_calls.positive?

        @remaining_calls -= 1
        attempts += 1
        @assistant.run(auto_tool_execution: false)
      rescue IOError
        retry if attempts < 2 && @remaining_calls.positive?

        raise
      end
    end

    def execute_tools
      calls = @assistant.messages.last.tool_calls
      raise ArgumentError, 'Too many tool calls' if calls.size > 4

      calls.each do |call|
        id, name, method, arguments = @assistant.llm_adapter.extract_tool_call_args(tool_call: call)
        unless name == TicketLookup.tool_name && method == 'lookup'
          raise TicketLookup::NotAuthorized, 'Unknown tool function'
        end

        output = @tool.lookup(**arguments)
        @assistant.submit_tool_output(tool_call_id: id, output: output)
      end
    end
  end
end
