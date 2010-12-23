# a lot of code taken from tmtm's tserver v0.3.2a
# http://www.tmtm.org/ruby/tserver/

require 'socket'
require File.expand_path(File.join("forkpool", "default_logger"), File.dirname(__FILE__))
require File.expand_path(File.join("forkpool", "children"), File.dirname(__FILE__))
require File.expand_path(File.join("forkpool", "forkpool"), File.dirname(__FILE__))
require File.expand_path(File.join("forkpool", "child"), File.dirname(__FILE__))
