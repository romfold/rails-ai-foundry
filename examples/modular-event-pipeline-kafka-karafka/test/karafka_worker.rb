# frozen_string_literal: true

require_relative 'network_guard'
require_relative '../config/environment'

module FailOnce
  def call(raw)
    marker = ENV.fetch('FAIL_ONCE_MARKER')
    unless File.exist?(marker)
      File.write(marker, 'Injected transient consumer failure')
      puts 'Injected transient consumer failure; Karafka must retry the batch.'
      raise IOError, 'Injected transient consumer failure'
    end
    super
  end
end

Pipeline::Receive.prepend(FailOnce)
Karafka::Server.execution_mode = :standalone
Karafka::Server.run
