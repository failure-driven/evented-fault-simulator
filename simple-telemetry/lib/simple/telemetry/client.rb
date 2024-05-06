# frozen_string_literal: true

require "socket"
require "securerandom"
require "json"

module Simple
  module Telemetry
    class Client
      def initialize(trace_id: SecureRandom.uuid)
        @server = TCPSocket.open(
          ENV.fetch("SIMPLE_TELEMETRY_HOST"),
          ENV.fetch("SIMPLE_TELEMETRY_PORT")
        )
        @trace_id = trace_id
        @start_time_monotonic = Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
        # TODO: extract json messaes to Simple::Telemetry::JsonSerailizer
        @server.puts({
          traceId: @trace_id,
          name: self.class,
          event: :processStarted,
          timeUnixNano: Process.clock_gettime(Process::CLOCK_REALTIME, :nanosecond),
          attributes: [
            {
              key: :pid,
              value: {
                type: :integer,
                value: Process.pid
              }
            }
          ]
        }.to_json)
        at_exit { stop } unless defined? RSpec # untested?
      end

      # TODO: overwrite certain methods to attach telemetry
      def puts(*args)
        # TODO: extract json messaes to Simple::Telemetry::JsonSerailizer
        @server.puts({
          traceId: @trace_id,
          name: self.class,
          event: :processingPerformed,
          timeUnixNano: Process.clock_gettime(Process::CLOCK_REALTIME, :nanosecond),
          attributes: [
            {
              key: :args,
              value: {
                stringValue: args.join(" ")
              }
            }
          ]
        }.to_json)
      end

      def stop
        # TODO: extract json messaes to Simple::Telemetry::JsonSerailizer
        @server.puts({
          traceId: @trace_id,
          name: self.class,
          event: :processStopped,
          timeUnixNano: Process.clock_gettime(Process::CLOCK_REALTIME, :nanosecond),
          attributes: [
            {
              key: :pid,
              value: {
                type: :integer,
                value: Process.pid
              }
            },
            {
              key: :totalRuntime,
              value: {
                type: :number,
                unit: :nanoseconds,
                value: Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond) - @start_time_monotonic
              }
            }
          ]
        }.to_json)
        @server.close
      end
    end
  end
end
