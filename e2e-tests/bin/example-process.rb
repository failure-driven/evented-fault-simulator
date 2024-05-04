#!/usr/bin/env ruby

require 'socket'

server = nil
begin
  server = TCPSocket.open(
    ENV.fetch("SIMPLE_TELEMETRY_HOST"),
    ENV.fetch("SIMPLE_TELEMETRY_PORT")
  )
  server.puts "CLIENT: processStarted"
  3.times do
    server.puts "processingPerformed: " + "hello #{ARGV.join(" ")}"
    sleep 1
  end
  server.puts "CLIENT: stopping"
ensure
  server.close
end
