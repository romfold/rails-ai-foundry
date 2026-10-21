# frozen_string_literal: true

require 'socket'

module OfflineSockets
  def connect(*)
    raise IOError, 'Network is disabled in normal recipe acceptance'
  end

  alias connect_nonblock connect
end

Socket.prepend(OfflineSockets)
UDPSocket.prepend(OfflineSockets)
Socket.define_singleton_method(:tcp) { |*| raise IOError, 'Network is disabled in normal recipe acceptance' }
TCPSocket.define_singleton_method(:new) { |*| raise IOError, 'Network is disabled in normal recipe acceptance' }
TCPSocket.define_singleton_method(:open) { |*| raise IOError, 'Network is disabled in normal recipe acceptance' }
