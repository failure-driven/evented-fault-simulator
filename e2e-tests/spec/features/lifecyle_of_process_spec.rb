# frozen_string_literal: true

require "spec_helper"
require "timeout"

TIMEOUT_SECONDS = 10
feature "lifecycle of process" do
  before do
    @queue = Thread::Queue.new
    @process_runner = Support::ProcessRunner.new(
      File.join(File.dirname(__FILE__), "../../bin/example-process.rb")
    )
  end

  scenario "lifecycle" do
    @process_runner.run(queue: @queue) do
      Given "simple telemetry client is running" do
        expect(@queue.pop).to eq "CMD: START"
      end

      When "sample process starts"
      Then "telemetry client receives ProcessStarted message"
      When "process performs some processing 3 times"
      Then "telemetry client receives 3x ProcessingPerformed messages"
      When "process terminates"
      Then "telemetry client receives ProcessTerminated message"
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
