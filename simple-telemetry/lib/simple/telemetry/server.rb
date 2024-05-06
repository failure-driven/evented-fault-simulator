# frozen_string_literal: true

require "socket"
require "securerandom"
require "json"
if ENV.fetch("SIMPLE_TELEMETRY_WEB_SERVER", false)
  require "rack"
  require "rackup"
end

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
        @port = ENV.fetch("SIMPLE_TELEMETRY_WEB_PORT", 9292)
        @start_time_monotonic = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
        @trace_id = SecureRandom.uuid
        @queue = Thread::Queue.new
      end

      def run
        setup_signal_traps
        setup_healthcheck
        start_web_server if ENV.fetch("SIMPLE_TELEMETRY_WEB_SERVER", false)
        if @single_threaded
          puts "SIMPLE TELEMETRY: single threaded mode"
          @queue << "SIMPLE TELEMETRY: single threaded mode"
          single_threaded_runner
        else
          mulit_threaded_runner
        end
      end

      private

      def start_web_server
        app = lambda do |env|
          body = proc do |stream|
            while (data = @queue.pop)
              stream.write format(
                <<~EO_MESSAGE,
                  id: %<id>s
                  event: %<event>s
                  data: %<data>s

                EO_MESSAGE
                id: SecureRandom.uuid,
                event: "status",
                data: data
              )
            end
          end
          [
            200,
            {
              "Content-Type" => "text/event-stream",
              "cache-control" => "no-cache",
              "allow-origin" => "*",
              "Access-Control-Allow-Origin" => "*"
            },
            body
          ]
        end
        # TODO: port ignored by Webrick under ruby 3.3.1
        server = Rackup::Server.new(app: app, port: @port)
        @web_server = Thread.new { server.start }
      end

      def single_threaded_runner
        client = @server.accept
        while (input = client.gets)
          puts "RECEIVED: #{input}"
          @queue << input
          input_json = JSON.parse(input)
          break if input_json.dig("event") == "processStopped"
        end
      end

      def mulit_threaded_runner
        loop do
          Thread.start(@server.accept) do |client|
            while (input = client.gets)
              puts "RECEIVED: #{input}"
              @queue << input
              input_json = JSON.parse(input)
              Thread.kill(self) if input_json.dig("event") == "processStopped"
            end
          end
        end.join
      end

      def stop
        puts "SIMPLE TELEMETRY: stopping"
        @queue << "SIMPLE TELEMETRY: stopping"
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
        puts "SIMPLE TELEMETRY: server #{@web_server.status}" if @web_server
        # TODO: extract json messaes to Simple::Telemetry::JsonSerailizer
        @queue << {
          traceId: @trace_id,
          name: self.class,
          event: :serverHealthcheck,
          timeUnixNano: Process.clock_gettime(Process::CLOCK_REALTIME, :nanosecond),
          attributes: [
            {
              key: :status,
              value: {
                stringValue: :healthy
              }
            },
            {
              key: :upTime,
              value: {
                type: :number,
                unit: :nanoseconds,
                value: Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond) - @start_time_monotonic
              }
            },
            {
              key: :webServerStatus,
              value: {
                stringValue: @web_server && @web_server.status
              }
            }
          ]
        }.to_json
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
