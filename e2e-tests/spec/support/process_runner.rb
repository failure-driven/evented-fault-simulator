# frozen_string_literal: true

module Support
  class ProcessRunner
    def initialize(env_vars: {}, command: )
      @env_vars = env_vars
      @command = command
    end

    def run(queue:)
      process = IO.popen(
        [
          @env_vars,
          *@command,
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

      if block_given?
        yield
      else
        Process.wait(process.pid)
      end
    ensure
      process.close
      # Process.kill("TERM", process.pid)
      # TODO: is a wait needed to make sure process is dead?
    end
  end
end