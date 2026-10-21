# frozen_string_literal: true

require 'test_helper'

class MediaTest < ActiveSupport::TestCase
  def test_authorization_bounded_buffer_and_interruption_fence
    session = Voice::Session.create!(tenant_id: 'a')
    change = Voice::ChangeTurn.new
    session = change.call(tenant_id: 'a', session_id: session.id, action: 'turn')
    buffer = Voice::MediaBuffer.new
    args = { tenant_id: 'a', session_id: session.id, epoch: session.epoch, sequence: 0, data: "\x00\x01".b }
    assert_raises(ActiveRecord::RecordNotFound) { buffer.push(**args, tenant_id: 'b') }
    assert_equal :accepted, buffer.push(**args)
    assert_equal :duplicate, buffer.push(**args)
    31.times { |i| assert_equal :accepted, buffer.push(**args, sequence: i + 1) }
    assert_equal :full, buffer.push(**args, sequence: 32)
    assert_raises(ArgumentError) { buffer.push(**args, data: 'x' * 4097) }
    interrupted = change.call(tenant_id: 'a', session_id: session.id, action: 'interrupt')
    assert_empty Voice::Frame.all
    assert_equal :stale, buffer.push(**args, sequence: 33)
    assert_nil buffer.shift(tenant_id: 'a', session_id: session.id, epoch: session.epoch)
    reconnect = change.call(tenant_id: 'a', session_id: session.id, action: 'reconnect')
    assert_operator reconnect.epoch, :>, interrupted.epoch
    active = change.call(tenant_id: 'a', session_id: session.id, action: 'turn')
    assert_equal :accepted, buffer.push(**args, epoch: active.epoch)
    assert_equal "\x00\x01".b, buffer.shift(tenant_id: 'a', session_id: session.id, epoch: active.epoch)
  end

  def test_concurrent_media_producers_share_one_durable_bound
    session = Voice::Session.create!(tenant_id: 'a')
    active = Voice::ChangeTurn.new.call(tenant_id: 'a', session_id: session.id, action: 'turn')
    threads = 4.times.map do |producer|
      Thread.new do
        ApplicationRecord.connection_pool.with_connection do
          20.times do |sequence|
            Voice::MediaBuffer.new.push(tenant_id: 'a', session_id: session.id, epoch: active.epoch,
                                        sequence: (producer * 20) + sequence, data: 'pcm')
          end
        end
      end
    end
    threads.each(&:value)
    assert_operator Voice::Frame.where(session_id: session.id).count, :<=, Voice::MediaBuffer::MAX_FRAMES
  end
end
