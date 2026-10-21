# frozen_string_literal: true

require_relative 'test_helper'
require 'open3'
require 'timeout'

class RebuildProcessTest < ActiveSupport::TestCase
  CHILD_SCRIPT = <<~CHILD
    $stdout.sync = true
    search = Rails.configuration.x.search
    barrier = -> { puts 'CHECKPOINT'; STDIN.read }
    if ENV.fetch('CHECKPOINT') == 'alias'
      index = search.instance_variable_get(:@index)
      original = index.method(:guarded_cutover)
      index.define_singleton_method(:guarded_cutover) do |*args, **kwargs|
        original.call(*args, **kwargs)
        barrier.call
      end
      search.resume_rebuild(ENV.fetch('RUN_ID'))
    else
      search.resume_rebuild(ENV.fetch('RUN_ID'), after_write: barrier)
    end
  CHILD

  test 'killed worker replays persisted destination write using the same candidate' do
    row = published
    run = @search.start_rebuild(destination: 'search')
    @search.resume_rebuild(run[:id])
    kill_at_checkpoint(run[:id], 'batch')
    assert_nil @search.rebuild_status(run[:id])[:page_key]
    expire_lease
    assert_equal run[:candidate], @search.rebuild_search(run_id: run[:id])
    assert_equal [row[:id]], @search.keyword(principal: @principal, query: 'refund').pluck(:id)
  end

  test 'killed worker after alias mutation reconciles before acknowledging locally' do
    row = published
    run = @search.start_rebuild(destination: 'search')
    @search.resume_rebuild(run[:id]) until @search.rebuild_status(run[:id])[:phase] == 'ready'
    kill_at_checkpoint(run[:id], 'alias')
    assert @search.rebuild_status(run[:id])[:cutover_intent]
    assert_equal 'cutting_over', @search.rebuild_status(run[:id])[:phase]
    transition(row, 'delete').value!
    expire_lease
    assert_equal run[:candidate], @search.rebuild_search(run_id: run[:id])
    assert_empty @search.keyword(principal: @principal, query: 'refund')
  end

  private

  def expire_lease
    ActiveRecord::Base.connection.execute("UPDATE search_rebuild_runs SET lease_until = now() - interval '1 minute'")
  end

  def kill_at_checkpoint(id, checkpoint)
    Open3.popen2e({ 'RAILS_ENV' => 'test', 'RUN_ID' => id, 'CHECKPOINT' => checkpoint },
                  'bin/rails', 'runner', CHILD_SCRIPT) do |_input, output, process|
      Timeout.timeout(30) do
        loop do
          line = output.gets || raise('Worker exited before synchronization')
          break if line.strip == 'CHECKPOINT'
        end
      end
      Process.kill('KILL', process.pid)
      assert process.value.signaled?
    ensure
      Process.kill('KILL', process.pid) if process.alive?
    end
  end
end
