module StdoutHook
  module Plugin
    class Test
      def initialize(opts = {})
      end

      def close
      end

      def send(tag, time, record)
        puts "tag = #{tag}, time = #{time}, record = #{record}"
      end
    end
  end
end
