$:.push File.expand_path("../lib", __FILE__)
require 'stdout_hook/version'

Gem::Specification.new do |s|
  s.name = "stdout-hook"
  s.version = StdoutHook::VERSION
  s.summary = "Easy to collect the event logs via STDOUT!"
  s.description = %q{Easy to collect the event logs via STDOUT for sending to TD or Fluentd}
  s.author = "Masahiro Nakagawa"
  s.email = "repeatedly@gmail.com"
  s.homepage = "https://github.com/treasure-data/stdout-hook"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n") 
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'td-logger', '~> 0.3.19'
  s.add_development_dependency 'bundler', '>= 1.0.0'
  s.add_development_dependency 'rake', '>= 0.8.7'
  s.add_development_dependency 'rspec', '>= 2.11'
end
