require 'spec'
require File.expand_path(File.join("..", "lib", "forkpool.rb"), File.dirname(__FILE__))

class Child < Forkpool
  attr_accessor :status
end

class Forkpool
  attr_reader :flag
end

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
