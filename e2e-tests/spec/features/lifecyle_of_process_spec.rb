require "spec_helper"

feature "lifecycle of process" do
  scenario "lifecycle" do
    Given "simple telemetry server is running"
    When "sample process starts"
    Then "telemetry server receives ProcessStarted message"
    When "process performs some processing 3 times"
    Then "telemetry server receives 3x ProcessingPerformed messages"
    When "process terminates"
    Then "telemetry server receives ProcessTerminated message"
  end
end
