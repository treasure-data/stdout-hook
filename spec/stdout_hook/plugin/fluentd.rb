require 'spec_helper'
require 'stdout_hook/plugin/spec_resources'
require 'stdout_hook/option'
require 'stdout_hook/plugin/fluentd'

describe StdoutHook::Plugin::Fluentd do
  require 'fluent/logger'

  let(:opt) {
    StdoutHook::Option.new
  }
  let(:plugin) {
    StdoutHook::Plugin::Fluentd.new(opt)
  }

  context 'close' do
    it 'closes the logger' do
      Fluent::Logger::FluentLogger.stub!(:new).and_return { |*args|
        logger = Object.new
        logger.should_receive(:close)
        logger
      }

      plugin.close
    end
  end

  context 'send' do
    include_context 'spec resources'

    it 'sends tag, time and record' do
      Fluent::Logger::FluentLogger.stub!(:new).and_return { |*args|
        logger = Object.new
        logger.should_receive(:post_with_time).with(tag, record, time)
        logger
      }

      plugin.send(tag, time, record)
    end
  end
end
