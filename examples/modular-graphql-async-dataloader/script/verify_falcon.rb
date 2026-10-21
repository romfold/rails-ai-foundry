# frozen_string_literal: true

require 'net/http'
require 'socket'
require 'timeout'

socket = TCPServer.new('127.0.0.1', 0)
port = socket.addr[1]
socket.close
command = ['bundle', 'exec', 'falcon', 'serve', '--bind', "http://127.0.0.1:#{port}",
           '--count', '1', '--no-restart']
puts "Running: #{command.join(' ')}"
pid = Process.spawn({ 'RAILS_ENV' => 'test' }, *command, pgroup: true)
begin
  Timeout.timeout(30) do
    loop do
      break if Net::HTTP.get_response(URI("http://127.0.0.1:#{port}/health")).code == '200'
    rescue Errno::ECONNREFUSED, EOFError
      sleep 0.1
    end
  end
  uri = URI("http://127.0.0.1:#{port}/graphql")
  request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json', 'Authorization' => 'Bearer demo-a')
  request.body = '{"query":"{ people(ids: []) { name } }"}'
  response = Net::HTTP.start(uri.host, uri.port) { |http| http.request(request) }
  raise response.body unless response.code == '200' && response.body.include?('"people":[]')

  puts 'Falcon served authenticated Rails GraphQL successfully.'
ensure
  Process.kill('TERM', -pid)
  Timeout.timeout(10) { Process.wait(pid) }
end
