#!/usr/bin/env ruby

# frozen_string_literal: true

$LOAD_PATH << File.join(File.dirname(__FILE__), "../../simple-telemetry/lib")

require "simple/telemetry/client"

# initialize
simple_telemetry = Simple::Telemetry::Client.new

3.times do
  # TODO: overwrite the methods that should hook into telemetry
  simple_telemetry.puts "hello #{ARGV.join(" ")}"
  sleep 1
end
