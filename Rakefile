require 'rubygems'
require 'rake'
require 'echoe'
require 'rspec/core/rake_task'

# Echoe.new('forkme', '0.0.5') do |p|
  # p.description    = "Manage a fork pool"
  # p.url            = "http://github.com/narshlob/forkme"
  # p.author         = "Tracey Eubanks"
  # p.email          = "traceye@pmamediagroup.com"
  # p.ignore_pattern = ["tmp/*", "script/*"]
  # p.development_dependencies = []
# end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }

RSpec::Core::RakeTask.new(:spec)
task :default => :spec
