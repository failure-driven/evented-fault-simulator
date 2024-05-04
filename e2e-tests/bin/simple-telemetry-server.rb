#!/usr/bin/env ruby

require 'socket'

module Simple
  module Telemetry
    class Server
      def initialize
        @server = TCPServer.open(
          ENV.fetch("SIMPLE_TELEMETRY_HOST"),
          ENV.fetch("SIMPLE_TELEMETRY_PORT")
        )
      end

      def run
        # TODO: single threaded
        client = @server.accept
        while(input = client.gets)
          puts "RECEIVED: #{input}"
          break if input == "CLIENT: stopping"
        end
      end
    end
  end
end

puts "SIMPLE TELEMETRY: starting"
server = Simple::Telemetry::Server.new
server.run
puts "SIMPLE TELEMETRY: stoping"