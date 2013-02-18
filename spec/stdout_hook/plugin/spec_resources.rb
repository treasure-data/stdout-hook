require 'spec_helper'

shared_context 'spec resources' do
  let(:tag) { 
    'plugin.spec'
  }
  let(:time) { 
    Time.now.to_i
  }
  let(:record) { 
    {'sushi' => 'tempura', 'yakiniku' => 'tsukemen'}
  }
  let(:input) {
    require 'json'
    StringIO.new("@[#{tag}] #{record.to_json}")
  }
end
