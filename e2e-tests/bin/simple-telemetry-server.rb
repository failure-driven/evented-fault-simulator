#!/usr/bin/env ruby

require 'socket'

module Simple
  module Telemetry
    class Server
      def initialize
        puts "SIMPLE TELEMETRY: starting"
        @server = TCPServer.open(
          ENV.fetch("SIMPLE_TELEMETRY_HOST"),
          ENV.fetch("SIMPLE_TELEMETRY_PORT")
        )
      end

      def run
        setup_signal_traps
        setup_healthcheck
        # TODO: single threaded
        client = @server.accept
        while(input = client.gets)
          puts "RECEIVED: #{input}"
          break if input == "CLIENT: stopping"
        end
      end

      private

      def stop
        puts "SIMPLE TELEMETRY: stopping"
      end

      def setup_signal_traps
        [
          "INT", # ^C
          "TERM", # kill
          "HUP"
        ].each do |signal|
          Signal.trap(signal) do
            stop
            exit
          end
        end
        Signal.trap("SIGUSR1") do
          healthcheck
        end
      end

      def healthcheck
        puts "SIMPLE TELEMETRY: healthcheck"
      end

      def setup_healthcheck
        Thread.new do
          loop do
            healthcheck
            sleep 1
          end
        end
      end
    end
  end
end

server = Simple::Telemetry::Server.new
server.run
