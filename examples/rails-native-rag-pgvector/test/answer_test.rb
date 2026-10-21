# frozen_string_literal: true

require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  def test_answers_use_authorized_evidence_and_reject_fabricated_citations
    Knowledge::Ingest.new.call(tenant_id: 'a', title: 'Policy', body: 'Return money within 30 days.')
    answer = Knowledge::Answer.new.call(tenant_id: 'a', question: 'refund')
    assert_includes answer.fetch('text'), '30 days'
    assert_equal 1, answer.fetch('citations').size
    assert_equal [], Knowledge::Answer.new.call(tenant_id: 'b', question: 'refund').fetch('citations')
    fabricated = ->(**) { { 'text' => 'Made up', 'citations' => ['document:999#passage-0'] } }
    assert_raises(ArgumentError) do
      Knowledge::Answer.new(generator: fabricated).call(tenant_id: 'a', question: 'refund')
    end
    unavailable = ->(**) { raise IOError, 'provider unavailable' }
    assert_raises(IOError) { Knowledge::Answer.new(generator: unavailable).call(tenant_id: 'a', question: 'refund') }
  end

  def test_provider_adapter_uses_pack_prompt_and_native_schema_without_network
    fake = Object.new
    calls = []
    fake.define_singleton_method(:with_instructions) do |text|
      calls << text
      self
    end
    fake.define_singleton_method(:with_schema) do |schema|
      calls << schema
      self
    end
    fake.define_singleton_method(:ask) do |text|
      calls << JSON.parse(text)
      Struct.new(:content).new({ 'text' => 'Evidence', 'citations' => ['document:1#passage-0'] })
    end
    result = Knowledge::ProviderAnswer.new(chat: fake).call(question: 'refund', passages: [])
    assert_equal 'Evidence', result.fetch('text')
    assert_includes calls.first, 'Cite each factual claim'
    assert_equal Knowledge::AnswerSchema, calls[1]
    assert_equal 'refund', calls.last.fetch('question')
  end
end
