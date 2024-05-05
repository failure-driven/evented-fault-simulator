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

      expect(socket).to have_received(:puts).with(
        "CLIENT(#{Process.pid}): processStarted"
      )
    end

    describe "#puts" do
      it "writes the message to the socket" do
        Simple::Telemetry::Client.new.puts("a message to puts")

        expect(socket).to have_received(:puts).with(
          "processingPerformed(#{Process.pid}): a message to puts"
        )
      end
    end

    describe "#stop" do
      it "writes a message and stops the socket" do
        Simple::Telemetry::Client.new.stop

        expect(socket).to have_received(:puts).with(
          "CLIENT(#{Process.pid}): stopping"
        )
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
