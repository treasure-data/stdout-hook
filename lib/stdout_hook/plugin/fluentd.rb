module StdoutHook
  module Plugin
    class Fluentd
      def initialize(opt)
        require 'fluent/logger'

        host = opt.host || 'localhost'
        port = opt.port || 24224

        @logger = Fluent::Logger::FluentLogger.new(nil, :host => host, :port => port)
      end

      def close
        @logger.close
      end

      def send(tag, time, record)
        @logger.post_with_time(tag, record, time)
      end
    end
  end
end
