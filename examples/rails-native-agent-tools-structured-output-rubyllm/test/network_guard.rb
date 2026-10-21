# frozen_string_literal: true

require 'socket'

# Integration tests may reach only disposable loopback services, never model providers.
module NetworkGuard
  module LocalConnectionsOnly
    def connect(address, ...)
      verify_local!(address)
      super
    end

    def connect_nonblock(address, ...)
      verify_local!(address)
      super
    end

    private

    def verify_local!(address)
      return if address.is_a?(String) && address.start_with?("\x01")

      host = address.is_a?(Addrinfo) ? address.ip_address : Socket.unpack_sockaddr_in(address).last
      raise "External network blocked: #{host}" unless ['127.0.0.1', '::1'].include?(host)
    end
  end

  module LocalTCPOnly
    def new(host, ...)
      # Selenium probes local interface binds; this is not an outbound connection.
      return super if self <= TCPServer

      raise "External network blocked: #{host}" unless ['127.0.0.1', 'localhost', '::1'].include?(host)

      super
    end
    alias open new
  end
end

Socket.prepend(NetworkGuard::LocalConnectionsOnly)
TCPSocket.singleton_class.prepend(NetworkGuard::LocalTCPOnly)
