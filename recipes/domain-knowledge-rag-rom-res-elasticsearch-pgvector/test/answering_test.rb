# frozen_string_literal: true

require_relative 'test_helper'
require 'minitest/mock'

class AnsweringTest < ActiveSupport::TestCase
  test 'answers cite only currently authorized evidence' do
    row = published
    drain
    answers = Answering::Answers.new(catalog: @catalog, search: @search)
    result = answers.call(principal: @principal, question: 'refund')
    assert_equal [row[:id]], result.fetch('citations')
    assert_includes result.fetch('text'), 'thirty days'
    other = Access::Identity.authenticate('demo-b')
    assert_empty answers.call(principal: other, question: 'refund').fetch('citations')
  end

  test 'tools reject revoked credentials before executing retrieval' do
    tool = Answering::RetrieveEvidence.new(principal: @principal, search: @search)
    previous = ENV.fetch('DEMO_TOKENS', nil)
    ENV['DEMO_TOKENS'] = '{}'
    assert_raises(Access::Identity::Denied) { tool.execute(query: 'refund') }
  ensure
    ENV['DEMO_TOKENS'] = previous
  end

  test 'provider cannot invent citations or use evidence withdrawn during generation' do
    row = published
    drain
    invalid = ->(**) { { 'text' => 'Invented', 'citations' => ['other-tenant-id'] } }
    answers = Answering::Answers.new(catalog: @catalog, search: @search, provider: invalid)
    assert_raises(Answering::Answers::InvalidCitation) { answers.call(principal: @principal, question: 'refund') }
    withdrawn = lambda do |**|
      transition(row, 'withdraw').value!
      { 'text' => 'Old content', 'citations' => [row[:id]] }
    end
    answers = Answering::Answers.new(catalog: @catalog, search: @search, provider: withdrawn)
    assert_raises(Answering::Answers::InvalidCitation) { answers.call(principal: @principal, question: 'refund') }
  end

  test 'native RubyLLM adapter uses its pack prompt and schema without network calls' do
    chat = Object.new
    captured = {}
    chat.define_singleton_method(:with_instructions) do |text|
      captured[:instructions] = text
      self
    end
    chat.define_singleton_method(:with_schema) do |schema|
      captured[:schema] = schema
      self
    end
    chat.define_singleton_method(:ask) do |text|
      captured[:message] = JSON.parse(text)
      Struct.new(:content).new({ 'text' => 'No evidence', 'citations' => [] })
    end
    response = Answering::ProviderAnswer.new(model: 'explicit-test-model', chat: chat).call(question: 'refund',
                                                                                            evidence: [])
    assert_empty response.fetch('citations')
    assert_includes captured[:instructions], 'untrusted'
    assert_equal Answering::AnswerSchema, captured[:schema]
    assert_equal 'refund', captured[:message].fetch('question')
  end
  test 'native embedding adapter passes explicit model and dimensions to RubyLLM' do
    calls = []
    vector = Search::DemoEmbeddings.new.call('refund')
    fake = lambda do |text, **options|
      calls << [text, options]
      Struct.new(:vectors).new(vector)
    end
    RubyLLM.stub(:embed, fake) do
      assert_equal vector, Search::ProviderEmbeddings.new(model: 'test-model').call('refund')
    end
    assert_equal [['refund', { model: 'test-model', dimensions: 1536 }]], calls
  end

  test 'provider failures emit safe measurements and do not fabricate answers' do
    published
    drain
    measurements = []
    subscriber = ActiveSupport::Notifications.subscribe('answer_provider.knowledge') do |*args|
      measurements << args.last
    end
    provider = ->(**) { raise IOError, 'credential and document content must stay private' }
    answers = Answering::Answers.new(catalog: @catalog, search: @search, provider: provider)
    assert_raises(IOError) { answers.call(principal: @principal, question: 'refund') }
    assert_equal 'failure', measurements.first.fetch(:outcome)
    assert_equal 'IOError', measurements.first.fetch(:error)
    assert_operator measurements.first.fetch(:duration_ms), :>=, 0
    refute_includes measurements.to_json, 'credential'
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end
  test 'offline guard blocks Socket and Net HTTP TCP entry points before connection' do
    assert_raises(RuntimeError) { Socket.tcp('external.invalid', 443) }
    assert_raises(RuntimeError) { TCPSocket.new('external.invalid', 443) }
    assert_raises(RuntimeError) { TCPSocket.open('external.invalid', 443) }
  end
end
