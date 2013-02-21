module StdoutHook
  module Plugin
    class TD
      attr_reader :loggers

      def initialize(opt)
        require 'td/client'
        require 'td/logger'

        @opts = {:apikey => opt.apikey, :use_ssl => opt.use_ssl, :auto_create_table => true}
        @loggers = {}
      end

      def close
        @loggers.each_value { |logger|
          logger.close
        }
      end

      def send(tag, time, event)
        db, table = tag.split('.', 2)
        db = TreasureData::API.normalize_table_name(db)
        table = TreasureData::API.normalize_database_name(table)

        logger = get_logger(db)
        logger.post_with_time(table, event, time)
      end

      private

      def get_logger(db)
        if @loggers.has_key?(db)
          @loggers[db]
        else
          logger = TreasureData::Logger::TreasureDataLogger.new(db, @opts)
          @loggers[db] = logger
          logger
        end
      end
    end
  end
end
