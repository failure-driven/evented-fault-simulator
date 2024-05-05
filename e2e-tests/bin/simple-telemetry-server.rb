#!/usr/bin/env ruby

# frozen_string_literal: true

$LOAD_PATH << File.join(File.dirname(__FILE__), "../../simple-telemetry/lib")

require "simple/telemetry/server"

server = Simple::Telemetry::Server.new
server.run
