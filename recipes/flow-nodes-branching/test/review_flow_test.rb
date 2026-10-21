# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'network_guard'
require_relative '../lib/review_flow'

class ReviewFlowTest < Minitest::Test
  def setup
    @effects = ReviewFlow::Effects.new
  end

  def test_branching_selects_review_or_delivery
    assert_equal :needs_review, run_flow(classifier: ->(*) { :review })[:status]
    assert_empty @effects.entries
    assert_equal({ status: :delivered, value: 'Evidence' }, run_flow(classifier: ->(*) { :deliver }))
    assert_equal({ 'request-1' => 'Evidence' }, @effects.entries)
  end

  def test_classification_retries_are_bounded_and_failed_work_does_not_deliver
    attempts = 0
    classifier = lambda do |_text|
      attempts += 1
      raise IOError, 'Unavailable' if attempts < 3

      :deliver
    end
    assert_equal :delivered, run_flow(classifier: classifier)[:status]
    assert_equal 3, attempts
    failing_attempts = 0
    assert_raises(IOError) do
      run_flow(request_id: 'failed', classifier: lambda { |*|
        failing_attempts += 1
        raise IOError
      })
    end
    assert_equal 3, failing_attempts
    refute @effects.entries.key?('failed')
  end

  def test_lost_acknowledgment_and_repeat_do_not_duplicate_effects
    acknowledgments = 0
    after_write = lambda do
      acknowledgments += 1
      raise IOError, 'Acknowledgment lost after effect' if acknowledgments == 1
    end
    assert_equal :delivered, run_flow(after_write: after_write)[:status]
    assert_equal 2, acknowledgments
    assert_equal :delivered, run_flow[:status]
    assert_equal 1, @effects.entries.size
    assert_raises(ArgumentError) { run_flow(text: 'Conflicting content') }
    assert_equal 'Evidence', @effects.entries.fetch('request-1')
  end

  def test_interruption_before_and_after_an_effect_is_explicit
    assert_equal :interrupted, run_flow(classifier: ->(*) { raise Interrupt })[:status]
    assert_empty @effects.entries
    assert_equal :interrupted, run_flow(after_write: -> { raise Interrupt })[:status]
    assert_equal 1, @effects.entries.size, 'interruption cannot undo an already committed effect'
    assert_equal :delivered, run_flow[:status]
    assert_equal 1, @effects.entries.size
  end

  def test_independent_requests_do_not_share_output_or_parameters
    run_flow
    result = run_flow(request_id: 'request-2', text: 'Other', classifier: ->(*) { :review })
    assert_equal({ status: :needs_review }, result)
    assert_equal({ 'request-1' => 'Evidence' }, @effects.entries)
  end

  def test_unsupported_routes_fail_without_effects_and_network_is_blocked
    assert_raises(ArgumentError) { run_flow(classifier: ->(*) { :unknown }) }
    assert_empty @effects.entries
    assert_raises(IOError) { TCPSocket.new('127.0.0.1', 1) }
  end

  private

  def run_flow(**overrides)
    ReviewFlow.call(request_id: 'request-1', text: 'Evidence', effects: @effects,
                    classifier: ->(*) { :deliver }, **overrides)
  end
end
