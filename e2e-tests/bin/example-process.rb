#!/usr/bin/env ruby

require 'socket'

module Simple
  class Telemetry
    def initialize
      @server = TCPSocket.open(
        ENV.fetch("SIMPLE_TELEMETRY_HOST"),
        ENV.fetch("SIMPLE_TELEMETRY_PORT")
      )
      @server.puts "CLIENT(#{Process.pid}): processStarted"
      at_exit { self.stop }
    end

    # TODO: overwrite certain methods to attach telemetry
    def puts(*args)
      @server.puts("processingPerformed(#{Process.pid}): #{args.join(" ")}")
    end

    def stop
      @server.puts "CLIENT(#{Process.pid}): stopping"
      @server.close
    end
  end
end

# initialize
simple_telemetry = Simple::Telemetry.new

3.times do
  simple_telemetry.puts "hello #{ARGV.join(" ")}"
  sleep 1
end
