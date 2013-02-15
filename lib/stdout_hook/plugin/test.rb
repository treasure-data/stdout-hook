module StdoutHook
  module Plugin
    class Test
      def initialize(opt)
      end

      def close
      end

      def send(tag, time, record)
        puts "tag = #{tag}, time = #{time}, record = #{record}"
      end
    end
  end
end
