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
        @single_threaded = ENV.fetch("SIMPLE_TELEMETRY_SINGLE_THREADED", false)
      end

      def run
        setup_signal_traps
        setup_healthcheck
        if @single_threaded
          puts "SIMPLE TELEMETRY: single threaded mode"
          single_threaded_runner
        else
          mulit_threaded_runner
        end
      end

      private

      def single_threaded_runner
        client = @server.accept
        while(input = client.gets)
          puts "RECEIVED: #{input}"
          break if input == "CLIENT: stopping"
        end
      end

      def mulit_threaded_runner
        loop do
          Thread.start(@server.accept) do |client|
            while(input = client.gets)
              puts "RECEIVED: #{input}"
              Thread.kill(self) if input == "CLIENT: stopping"
            end
          end
        end.join
      end

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
