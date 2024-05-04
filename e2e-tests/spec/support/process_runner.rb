# frozen_string_literal: true

module Support
  class ProcessRunner
    def initialize(command)
      @command = command
    end

    def run(queue:)
      process = IO.popen(
        [
          {},
          @command,
          {err: %i[child out]},
        ],
      )

      Thread.new do
        queue << "CMD: START"
        while (output_line = process.gets)
          queue << output_line
        end
        queue << "CMD: END"
      end

      yield
    ensure
      Process.kill("TERM", process.pid)
      # TODO: is a wait needed to make sure process is dead?
    end
  end
end