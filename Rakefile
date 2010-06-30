require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('loompa', '0.0.2') do |p|
  p.description    = "Manage a fork pool"
  p.url            = "http://github.com/pmamediagroup/loompa"
  p.author         = "Tracey Eubanks"
  p.email          = "traceye@pmamediagroup.com"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }

