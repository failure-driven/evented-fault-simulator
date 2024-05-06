# frozen_string_literal: true

require "spec_helper"
require "simple/telemetry/client"

RSpec.describe Simple::Telemetry::Client do
  context "with required configuration" do
    let(:socket) { instance_double(TCPSocket, puts: nil, close: nil) }
    before do
      ENV["SIMPLE_TELEMETRY_HOST"] = "the-host"
      ENV["SIMPLE_TELEMETRY_PORT"] = "the-port"

      allow(TCPSocket).to receive(:open).and_return(socket)
    end

    it "opens a TCPSocket with the configured host and port" do
      Simple::Telemetry::Client.new

      expect(TCPSocket).to have_received(:open).with("the-host", "the-port")
    end

    it "writes to the socket it has started" do
      Simple::Telemetry::Client.new

      # TODO: move json out to Simple::Telemetry::JsonSerailizer
      #       or use a socket writer wrapper to assert HASH and not JSON
      expect(socket).to have_received(:puts) do |message|
        expect(JSON.parse(message)).to match(
          hash_including(
            "event" => "processStarted",
            "name" => "Simple::Telemetry::Client",
            "timeUnixNano" => kind_of(Integer),
            "traceId" => kind_of(String),
            "attributes" => [
              {"key" => "pid", "value" => {"type" => "integer", "value" => Process.pid}}
            ]
          )
        )
      end
    end

    describe "#puts" do
      it "writes the message to the socket" do
        Simple::Telemetry::Client.new.puts("a message to puts")

        # TODO: move json out to Simple::Telemetry::JsonSerailizer
        #       or use a socket writer wrapper to assert HASH and not JSON
        expect(socket).to have_received(:puts).with(/processStarted/)
        expect(socket).to have_received(:puts).with(/processingPerformed/) do |message|
          expect(JSON.parse(message)).to match(
            hash_including(
              "event" => "processingPerformed",
              "name" => "Simple::Telemetry::Client",
              "timeUnixNano" => kind_of(Integer),
              "traceId" => kind_of(String),
              "attributes" => [
                {"key" => "args", "value" => {"stringValue" => "a message to puts"}}
              ]
            )
          )
        end
      end
    end

    describe "#stop" do
      it "writes a message and stops the socket" do
        Simple::Telemetry::Client.new.stop

        # TODO: move json out to Simple::Telemetry::JsonSerailizer
        #       or use a socket writer wrapper to assert HASH and not JSON
        expect(socket).to have_received(:puts).with(/processStarted/)
        expect(socket).to have_received(:puts).with(/processStopped/) do |message|
          expect(JSON.parse(message)).to match(
            hash_including(
              "event" => "processStopped",
              "name" => "Simple::Telemetry::Client",
              "timeUnixNano" => kind_of(Integer),
              "traceId" => kind_of(String),
              "attributes" => [
                {"key" => "pid", "value" => {"type" => "integer", "value" => Process.pid}},
                {"key" => "totalRuntime", "value" => {"type" => "number", "unit" => "nanoseconds", "value" => kind_of(Integer)}}
              ]
            )
          )
        end
        expect(socket).to have_received(:close)
      end
    end
  end

  context "without mandatory environment variables" do
    before do
      ENV.delete("SIMPLE_TELEMETRY_HOST")
      ENV.delete("SIMPLE_TELEMETRY_PORT")
    end

    it "complains bitterly" do
      expect {
        Simple::Telemetry::Client.new
      }.to raise_error(KeyError)
    end
  end
end
