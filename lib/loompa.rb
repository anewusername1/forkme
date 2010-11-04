# a lot of code taken from tmtm's tserver v0.3.2a
# http://www.tmtm.org/ruby/tserver/

require 'socket'
require File.expand_path(File.join("loompa", "default_logger"), File.dirname(__FILE__))
require File.expand_path(File.join("loompa", "children"), File.dirname(__FILE__))
require File.expand_path(File.join("loompa", "loompa"), File.dirname(__FILE__))
require File.expand_path(File.join("loompa", "child"), File.dirname(__FILE__))

# Dir.glob(File.expand_path(File.join("loompa", "*"), File.dirname(__FILE__))).each do |f|
#   require f
# end
