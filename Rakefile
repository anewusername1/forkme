require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('forkpool', '0.0.4') do |p|
  p.description    = "Manage a fork pool"
  p.url            = "http://github.com/narshlob/forkpool"
  p.author         = "Tracey Eubanks"
  p.email          = "traceye@pmamediagroup.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }

