# frozen_string_literal: true

module LoopbackOnly
  def self.check!(host)
    raise 'External network disabled in acceptance' unless %w[localhost 127.0.0.1 ::1].include?(host)
  end

  module SocketMethods
    def tcp(host, ...)
      LoopbackOnly.check!(host)
      super
    end
  end

  module TCPMethods
    def new(host, ...)
      LoopbackOnly.check!(host)
      super
    end

    def open(host, ...)
      LoopbackOnly.check!(host)
      super
    end
  end
end
