# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

module Knowledge
  class ProviderError < StandardError; end

  class Http
    def initialize(endpoint:, headers: {})
      @uri = URI(endpoint)
      valid = @uri.is_a?(URI::HTTPS) || (@uri.is_a?(URI::HTTP) && %w[localhost 127.0.0.1].include?(@uri.host))
      raise ArgumentError, 'Use HTTPS or explicit loopback HTTP' unless valid && !@uri.userinfo

      @headers = { 'Content-Type' => 'application/json' }.merge(headers)
    end

    def perform(request)
      Net::HTTP.start(@uri.host, @uri.port, use_ssl: @uri.scheme == 'https',
                                            open_timeout: 2, read_timeout: 5, write_timeout: 5,
                                            max_retries: 0) { |http| http.request(request) }
    end
    private :perform

    def call(method, path, body = nil)
      request = Net::HTTP.const_get(method.capitalize).new(path, @headers)
      request.body = JSON.generate(body) if body
      response = perform(request)
      raise ProviderError, "Provider HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body.to_s.empty? ? {} : JSON.parse(response.body)
    rescue JSON::ParserError, IOError, SystemCallError, Timeout::Error => e
      raise ProviderError, "Provider response failed: #{e.class}"
    end
  end
end
