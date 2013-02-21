require 'stdout_hook/option'
require 'stdout_hook/router'

module StdoutHook
  class Runner
    def self.run(argv)
      opt = Option.parse(argv)
      router = Router.new(opt)

      if opt.command.nil?
        run_with_stdin(router, opt)
      else
        run_with_spawn(router, opt)
      end
    end

    def self.run_with_spawn(router, opt)
      input, output = IO.pipe
      pid = spawn(opt.command, :out => output)
      output.close

      if pid.nil?
        raise "Failed to spawn the child process"
      end

      [:USR1, :USR2, :HUP, :QUIT, :INT, :TERM].each { |signal|
        trap(signal) {
          puts "SIG#{signal} received"
          router.parse(input)  # This line is needed to prevent logs loss
          router.close
          Process.kill(signal, pid)
        }
      }

      begin
        router.parse(input)
      rescue => e
        Process.kill(:TERM, pid)
        print_error(e)
      end
    end

    def self.run_with_stdin(router, opt)
      router.parse(STDIN)
    rescue Interrupt
      router.parse(STDIN)  # same as trap in run_with_spawn
      router.close
    rescue => e
      print_error(e)
    end

    def self.print_error(error)
      time = Time.now
      $stderr.puts "#{time}: #{error.message}"
      error.backtrace.each { |msg|
        $stderr.puts "  #{time}: #{msg}"
      }
    end
  end
end
