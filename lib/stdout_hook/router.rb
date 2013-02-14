require 'stdout_hook/plugin/td'
require 'stdout_hook/plugin/fluentd'
require 'stdout_hook/plugin/test'

module StdoutHook
  class Router
    def initialize(opt)
      require 'yajl'

      @plugin = load_plugin(opt)
      @regexp = /^@\[(?<tag>[^ ]*)\] (?<record>{.*})$/
      # @regexp = /^@\[(?<db>[^ ]*)\.(?<table>[^ ]*)\] (?<record>{.*})$/
    end

    def parse(input)
      until input.eof?
        break unless log = input.gets

        text = log.strip
        m = @regexp.match(text)
        unless m
          puts text
          next
        end

        route(m['tag'], Time.now.to_i, Yajl.load(m['record']))
      end
    end

    def route(tag, time, record)
      # TODO: Chain plugins?
      @plugin.send(tag, time, record)
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
