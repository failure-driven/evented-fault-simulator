#!/usr/bin/env ruby

require 'socket'

# server = nil
begin
  puts "SIMPLE TELEMETRY: starting"
  server = TCPServer.new(
    ENV.fetch("SIMPLE_TELEMETRY_HOST"),
    ENV.fetch("SIMPLE_TELEMETRY_PORT")
  )
  # TODO: single threaded
  client = server.accept
  while(input = client.gets)
    puts "RECEIVED: #{input}"
    break if input == "CLIENT: stopping"
  end
ensure
  puts "SIMPLE TELEMETRY: stoping"
  # client.close
  # server.close
end