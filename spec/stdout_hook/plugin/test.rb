require 'spec_helper'
require 'stdout_hook/plugin/test'

describe StdoutHook::Plugin::Test do
  let(:plugin) {
    StdoutHook::Plugin::Test.new(nil)
  }

  context 'send' do
    it 'dumps tag, time and record' do
      now = Time.now.to_i
      result = capture_stdout {
        plugin.send('plugin.spec', now, 'dummy_record')
      }

      expect(result).to eq("tag = plugin.spec, time = #{now}, record = dummy_record\n") 
    end
  end
end
