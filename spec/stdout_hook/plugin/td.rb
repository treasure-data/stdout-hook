require 'spec_helper'
require 'stdout_hook/plugin/spec_resources'
require 'stdout_hook/option'
require 'stdout_hook/plugin/td'

describe StdoutHook::Plugin::TD do
  let(:opt) {
    opt = StdoutHook::Option.new
    opt.instance_variable_set(:@apikey, 'test_api_key')
    opt
  }
  let(:plugin) {
    StdoutHook::Plugin::TD.new(opt)
  }

  context 'close' do
    it 'closes the logger' do
      plugin.loggers.should_receive(:each)
      plugin.close
    end
  end

  context 'send' do
    include_context 'spec resources'

    let(:table) {
      tag.split('.', 2).last
    }

    it 'sends tag, time and record' do
      TreasureData::Logger::TreasureDataLogger.stub!(:new).and_return { |*args|
        logger = Object.new
        logger.should_receive(:post_with_time).with(table, record, time)
        logger
      }

      plugin.send(tag, time, record)
    end

    context 'short tag' do
      let(:tag) {
        'a.b'
      }

      it 'sends tag, time and record' do
        TreasureData::Logger::TreasureDataLogger.stub!(:new).and_return { |*args|
          logger = Object.new
          logger.should_receive(:post_with_time).with(TreasureData::API.normalize_database_name(table), record, time)
          logger
        }

        plugin.send(tag, time, record)
      end
    end
  end
end
