# frozen_string_literal: true

require 'socket'

module OfflineNetwork
  def connect(*)
    raise 'Network access is forbidden in example tests'
  end
  alias connect_nonblock connect
end

Socket.prepend(OfflineNetwork)
UDPSocket.prepend(OfflineNetwork)
Socket.define_singleton_method(:tcp) { |*| raise 'Network access is forbidden in example tests' }
%i[new open].each do |method|
  TCPSocket.define_singleton_method(method) { |*| raise 'Network access is forbidden in example tests' }
end
