require 'rspec'
require 'fileutils'
# require 'fakefs'
require File.expand_path(File.join("..", "lib", "forkme.rb"), File.dirname(__FILE__))

class Child < Forkme
  attr_accessor :status
end

class Forkme
  attr_reader :flag, :children
  attr_accessor :on_child_start_blk, :on_child_exit_blk

  def self.children
    @@children
  end
end

RSpec.configure do |config|
  config.mock_with :mocha
end
