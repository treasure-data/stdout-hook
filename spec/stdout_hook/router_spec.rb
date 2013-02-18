require 'spec_helper'
require 'stdout_hook/option'
require 'stdout_hook/router'

describe StdoutHook::Router do
  let(:opt) {
    StdoutHook::Option.parse(%W(-m test))
  }

  context 'initialize' do
    {'td' => StdoutHook::Plugin::TD, 'fluentd' => StdoutHook::Plugin::Fluentd, 'test' => StdoutHook::Plugin::Test}.each_pair { |k, v|
      it "loads the plugin: #{k}" do
        router = StdoutHook::Router.new(StdoutHook::Option.parse(%W[-m #{k} -k test_api_key]))
        expect(router.plugin.is_a?(v)).to be_true
      end
    }

    it 'raises an exception with unknown mode' do
      mode = 'unknown'
      expect {
        StdoutHook::Router.new(StdoutHook::Option.parse(%W[-m #{mode}]))
      }.to raise_error(RuntimeError, /^Unsupported plugin type: #{mode}$/)
    end

    context 'parse' do
      include_context 'spec resources'

      let(:router) {
        StdoutHook::Router.new(opt)
      }

      it 'parses a valid line' do
        router.should_receive(:route).with(tag, anything, record)
        router.parse(input)
      end

      it 'parses the un-matched line' do
        line = "URRRRYYYYYYY!"
        result = capture_stdout {
          router.parse(StringIO.new(line))
        }

        expect(result).to eq("#{line}\n")
      end

      it 'parses a invalid record' do
        result = capture_stderr {
          router.parse(StringIO.new("@[#{tag}] {invalid}"))
        }

        expect(result).to match(/^Failed to parse JSON:/)
      end

      # TODO: route specs
    end
  end
end
