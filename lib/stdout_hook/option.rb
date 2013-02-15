module StdoutHook
  class Option
    def self.parse(argv)
      opt = Option.new
      opt.parse!(argv)
      opt
    end

    attr_reader :mode
    attr_reader :command

    # for TD
    attr_reader :apikey
    attr_reader :use_ssl

    # for fluentd
    attr_reader :host
    attr_reader :port

    def initialize
      require 'optparse'

      @mode = 'td'
      @apikey = ENV['TREASURE_DATA_API_KEY'] || ENV['TD_API_KEY']
      @use_ssl = false
      @opt = setup_options
    end

    def parse!(argv)
      require 'shellwords'

      @opt.parse!(argv)
      @command = Shellwords.shelljoin(argv) unless argv.empty?

      case @mode
      when 'td'
        raise "--apikey option is required on 'td' mode" if @apikey.nil?
      end
    end

    def [](key)
      instance_variable_get("@#{key}")
    end

    private

    def setup_options
      opt = OptionParser.new

      opt.on('-m', '--mode MODE', "Choose running mode (default: 'td')") { |s|
        @mode = s
      }
      opt.on('-p', '--port PORT', "fluentd tcp port (default: 24224)", Integer) { |i|
        @port = i
      }
      opt.on('-h', '--host HOST', "fluentd host (default: localhost)") { |s|
        @host = s
      }
      opt.on('-k', '--apikey KEY', "API key for TreasureData service") { |s|
        @apikey = s
      }
      opt.on('-s', '--use_ssl', "Enable SSL for uploading data to TreasureData service", TrueClass) { |b|
        @use_ssl = true
      }

      opt
    end
  end
end
