require 'spec_helper'
require 'stdout_hook/option'

describe StdoutHook::Option do
  describe 'parse!' do
    let(:option) {
      StdoutHook::Option.new
    }

    before { 
      ENV['TREASURE_DATA_API_KEY'] = 'test_api_key'
    }

    after {
      ENV['TREASURE_DATA_API_KEY'] = nil
    }

    ['td', 'fluentd', 'test'].each { |m|
      it "parses mode option: #{m}" do
        option.parse!(['--mode', m])

        expect(option.mode).to eq(m)
      end
    }

    context 'for td mode' do
      def parse(argv)
        option.parse!(argv)
      end

      it 'parses empty ARGV' do
        parse([])

        expect(option.mode).to eq('td')
        expect(option.apikey).to eq('test_api_key')
        expect(option.use_ssl).to be_false
      end

      ['-k', '--apikey'].each { |k|
        it "parses apikey option: #{k}" do
          parse([k, 'make_it_first'])

          expect(option.apikey).to eq('make_it_first')
        end
      }

      ['-s', '--use_ssl'].each { |s|
        it "parses use SSL option: #{s}" do
          parse([s])

          expect(option.use_ssl).to be_true
        end
      }

      context 'without apikey' do
        before { 
          ENV['TREASURE_DATA_API_KEY'] = nil
        }

        it 'parses empty ARGV' do
          expect {
            parse([])
          }.to raise_error(RuntimeError)
        end
      end
    end

    context 'for fluentd mode' do
      def parse(argv)
        option.parse!(['--mode', 'fluentd'] + argv)
      end

      ['-h', '--host'].each { |h|
        it "parses host option: #{h}" do
          parse([h, 'oreore'])

          expect(option.host).to eq('oreore')
        end
      }

      ['-p', '--port'].each { |p|
        it "parses port option: #{p}" do
          parse([p, '12345'])

          expect(option.port).to eq(12345)
        end
      }
    end
  end

  describe 'Option.parse' do
    it 'calls Option#parse!' do
      argv = ['--apikey', 'sushi']
      new_method = StdoutHook::Option.method(:new)
      StdoutHook::Option.stub!(:new).and_return do |*args|
        opt = new_method.call(*args)
        opt.should_receive(:parse!).and_return(argv)
        opt
      end

      StdoutHook::Option.parse(argv)
    end
  end
end
