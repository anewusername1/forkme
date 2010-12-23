require 'spec'
require File.expand_path(File.join("..", "lib", "forkpool.rb"), File.dirname(__FILE__))

class Child < Loompa
  attr_accessor :status
end

Spec::Runner.configure do |config|
  config.mock_with :flexmock
end
