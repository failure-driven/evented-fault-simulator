# frozen_string_literal: true

require "spec_helper"
require "simple/telemetry/server"

RSpec.describe Simple::Telemetry::Server do
  context "with required configuration" do
    let(:server) { instance_double(TCPServer) }
    before do
      ENV["SIMPLE_TELEMETRY_HOST"] = "the-host"
      ENV["SIMPLE_TELEMETRY_PORT"] = "the-port"

      allow(TCPServer).to receive(:open).and_return(server)
    end

    it "opens a TCPServer with the configured host and port" do
      Simple::Telemetry::Server.new

      expect(TCPServer).to have_received(:open).with("the-host", "the-port")
    end
  end
end
