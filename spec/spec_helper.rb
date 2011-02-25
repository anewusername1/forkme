require 'rspec'
require 'fileutils'
# require 'fakefs'
require File.expand_path(File.join("..", "lib", "forkpool.rb"), File.dirname(__FILE__))

class Child < Forkpool
  attr_accessor :status
end

class Forkpool
  attr_reader :flag, :children
  attr_accessor :on_child_start_blk, :on_child_exit_blk

  def children
    @@children
  end
end

RSpec.configure do |config|
  config.mock_with :mocha
end
