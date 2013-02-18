$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

if ENV['SIMPLE_COV']
  require 'simplecov'

  SimpleCov.start do
    add_filter 'spec/'
    add_filter 'pkg/'
    add_filter 'vendor/'
  end
end

require 'rspec'

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.mock_with :rspec
end

def capture_stdout(&block)
  original = $stdout
  captured = $stdout = StringIO.new

  begin
    yield
  ensure
    $stdout = original
  end

  captured.string
end

def capture_stderr(&block)
  original = $stderr
  captured = $stderr = StringIO.new

  begin
    yield
  ensure
    $stderr = original
  end

  captured.string
end
