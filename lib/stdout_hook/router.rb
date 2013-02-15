require 'stdout_hook/plugin/td'
require 'stdout_hook/plugin/fluentd'
require 'stdout_hook/plugin/test'

module StdoutHook
  class Router
    def initialize(opt)
      require 'yajl'

      @opt = opt
      @plugin = load_plugin(opt)
      @regexp = /^\s*@\[(?<tag>[^ ]*)\] (?<record>{.*})\s*$/
    end

    def parse(input)
      until input.eof?
        break unless log = input.gets

        m = @regexp.match(log)
        unless m
          puts log
          next
        end

        begin
          record = Yajl.load(m['record'])
        rescue => e
          STDERR.puts "Failed to parse JSON: #{e}"
          next
        end

        route(m['tag'], Time.now.to_i, record)
      end
    end

    def route(tag, time, record)
      # TODO: Chain plugins?
      begin 
        @plugin.send(tag, time, record)
      rescue => e
        STDERR.puts "Failed to send an event. Re-create a plugin: #{e}"
        @plugin = load_plugin(@opt)
        @plugin.send(tag, time, record)
      end
    end

    private

    def load_plugin(opt)
      case opt.mode
      when 'td'
        StdoutHook::Plugin::TD.new(opt)
      when 'fluentd'
        StdoutHook::Plugin::Fluentd.new(opt)
      when 'test'
        StdoutHook::Plugin::Test.new(opt)
      else
        raise "Unsupported plugin type: #{mode}"
      end
    end
  end
end
