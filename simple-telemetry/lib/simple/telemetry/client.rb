# frozen_string_literal: true

require "socket"

module Simple
  module Telemetry
    class Client
      def initialize
        @server = TCPSocket.open(
          ENV.fetch("SIMPLE_TELEMETRY_HOST"),
          ENV.fetch("SIMPLE_TELEMETRY_PORT")
        )
        @server.puts "CLIENT(#{Process.pid}): processStarted"
        at_exit { stop } unless defined? RSpec # untested?
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
end
