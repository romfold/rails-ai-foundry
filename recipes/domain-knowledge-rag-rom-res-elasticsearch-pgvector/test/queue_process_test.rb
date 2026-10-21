# frozen_string_literal: true

require_relative 'test_helper'
require 'timeout'
require 'tempfile'

class QueueProcessTest < ActiveSupport::TestCase
  test 'persisted wake-up runs in an independent Solid Queue process' do
    row = published
    ActiveRecord::Base.connection.execute('TRUNCATE solid_queue_jobs RESTART IDENTITY CASCADE')
    DeliveryPollJob.perform_later
    log = Tempfile.new('knowledge-queue')
    pid = Process.spawn({ 'RAILS_ENV' => 'test' }, RbConfig.ruby, 'bin/jobs', '--mode=async',
                        '--skip-recurring', out: log.path, err: %i[child out])
    Timeout.timeout(30) do
      sleep 0.1 until @catalog.queue.status.all? { |item| item[:state] == 'done' }
    end
    assert_equal([row[:id]], @search.keyword(principal: @principal, query: 'refund').map { |item| item[:id] })
    assert_empty SolidQueue::FailedExecution.all
  rescue Timeout::Error
    flunk "Solid Queue did not deliver persisted work:\n#{File.read(log.path)}"
  ensure
    if pid
      Process.kill('TERM', pid)
      begin
        Timeout.timeout(10) { Process.wait(pid) }
      rescue Timeout::Error
        Process.kill('KILL', pid)
        Process.wait(pid)
      end
    end
    log&.close!
  end
end
