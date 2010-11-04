require 'spec'
require File.expand_path(File.join("..", "lib", "loompa.rb"), File.dirname(__FILE__))

class Child < Loompa
  attr_accessor :status, :to, :from
end

Spec::Runner.configure do |config|
  config.mock_with :flexmock
end
