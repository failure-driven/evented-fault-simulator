# frozen_string_literal: true

require "spec_helper"
require "timeout"
require "securerandom"

TIMEOUT_SECONDS = 10
feature "lifecycle of process" do
  before do
    @queue = Thread::Queue.new
    @telemetry_service_runner = Support::ProcessRunner.new(
      env_vars: {
        "SIMPLE_TELEMETRY_HOST" => "localhost",
        "SIMPLE_TELEMETRY_PORT" => "1234",
        "SIMPLE_TELEMETRY_SINGLE_THREADED" => "true"
      },
      command: [
        File.join(File.dirname(__FILE__), "../../bin/simple-telemetry-server.rb")
      ]
    )
  end

  scenario "lifecycle" do
    Timeout.timeout(TIMEOUT_SECONDS) do
      @telemetry_service_runner.run(queue: @queue) do
        Given "simple telemetry client is running" do
          expect(@queue.pop).to eq "CMD: START"
        end

        When "sample process starts" do
          @uuid = SecureRandom.uuid
          @process_runner = Support::ProcessRunner.new(
            env_vars: {
              "SIMPLE_TELEMETRY_HOST" => "localhost",
              "SIMPLE_TELEMETRY_PORT" => "1234",
            },
            command: [
              File.join(File.dirname(__FILE__), "../../bin/example-process.rb"),
              @uuid
            ]
          )
          @process_runner.run(queue: @queue)
        end

        Then "telemetry client receives ProcessStarted message" do
          while (value = @queue.pop)
            break if value =~ /CLIENT/
          end
          expect(value.chomp).to match /RECEIVED: CLIENT\(\d+\): processStarted/
        end

        Then "telemetry client receives 3x ProcessingPerformed messages" do
          received = []
          while (value = @queue.pop)
            @last_value = value
            break if value =~ /CLIENT/
            if value =~ /RECEIVED/
              expect(value.chomp).to match /RECEIVED: processingPerformed\(\d+\): hello #{@uuid}/
              received << value.chomp
            end
          end
          expect(received).to match_array(
            [
              /RECEIVED: processingPerformed\(\d+\): hello #{@uuid}/,
              /RECEIVED: processingPerformed\(\d+\): hello #{@uuid}/,
              /RECEIVED: processingPerformed\(\d+\): hello #{@uuid}/
            ]
          )
        end

        And "telemetry client receives ProcessTerminated message" do
          expect(@last_value.chomp).to match /RECEIVED: CLIENT\(\d+\): stopping/
        end

        When "simple telemetry client stops" do
          Timeout.timeout(TIMEOUT_SECONDS) do
            while (value = @queue.pop)
              break if value == "CMD: END"
            end
            expect(value).to eq "CMD: END"
          end
        end
      end
    end
  end
end
