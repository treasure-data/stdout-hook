require 'stdout_hook/option'
require 'stdout_hook/router'

module StdoutHook
  class Runner
    def self.terminate_gracefully(pid, signal)
      return if pid.nil?
      
      begin
        Process.kill(signal, pid) rescue Errno::ESRCH
        Timeout.timeout(3) {
          pid, status = Process.wait2
          Kernel.exit (status.exitstatus || 0)
        }
      rescue Timeout::Error
        Process.kill("SIGKILL", pid) rescue Errno::ESRCH
      end
    end

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
        raise "failed to spawn the child process"
      end

      trap("INT") {
        puts "SIGINT received"
        router.parse(input)
        terminate_gracefully(pid, 'SIGINT')
      }
      trap("TERM") {
        puts "SIGTERM received"
        router.parse(input)
        terminate_gracefully(pid, 'SIGTERM')
      }

      begin
        router.parse(input)
      rescue => e
        terminate_gracefully(pid, 'SIGTERM')
        STDERR.puts "Unexpected error: message = #{e.message}"
      end
    end

    def self.run_with_stdin(router, opt)
      router.parse(STDIN)
    rescue Interrupt
      router.parse(STDIN)
    rescue => e
      STDERR.puts "Unexpected error: message = #{e.message}"
    end
  end
end
