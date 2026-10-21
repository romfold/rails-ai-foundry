# frozen_string_literal: true

require 'net/http'
require 'uri'
require_relative 'study'

module BenchmarkSuite
  class OpenrouterAccount
    MODEL = 'openai/gpt-5.6-luna'

    def initialize(key: ENV.fetch('OPENROUTER_API_KEY', ''))
      @key = key
    end

    def snapshot
      raise Failure, 'OPENROUTER_API_KEY is not set in this process' if @key.empty?

      account = request('/key').fetch('data')
      endpoint = selected_endpoint

      { 'account' => account.slice('limit', 'limit_remaining', 'limit_reset', 'usage'),
        'endpoint' => endpoint.slice('name', 'model_id', 'tag', 'provider_name', 'status',
                                     'supported_parameters', 'pricing'),
        'key_fingerprint' => Digest::SHA256.hexdigest(@key), 'model' => MODEL, 'captured_at' => Time.now.utc.iso8601 }
    rescue KeyError, JSON::ParserError
      raise Failure, 'Incomplete OpenRouter metadata'
    end

    private

    def selected_endpoint
      endpoints = request("/models/#{MODEL}/endpoints").fetch('data').fetch('endpoints')
      endpoint = endpoints.find { |item| item['tag'] == Study::PROVIDER }
      raise Failure, 'Requested OpenAI provider endpoint unavailable' unless endpoint

      endpoint
    end

    def request(path)
      uri = URI("https://openrouter.ai/api/v1#{path}")
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{@key}"
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 20) do |http|
        http.request(request)
      end
      raise Failure, "OpenRouter metadata HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    rescue IOError, SystemCallError, Timeout::Error, OpenSSL::SSL::SSLError
      raise Failure, 'OpenRouter metadata connection failed'
    end
  end
end
