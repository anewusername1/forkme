require File.expand_path(File.join('..', '..', '/spec_helper.rb'), File.dirname(__FILE__))

describe "Forkpool" do
  before(:each) do
    Process.kill "KILL", *(Forkpool.children.pids) rescue nil
    Process.wait *(Forkpool.children.pids) rescue ""
  end

  describe "self.logger" do
    it "should have a logger with info, debug, and error methods" do
      f = Forkpool.new(1)
      Forkpool.logger.should respond_to(:info)
      Forkpool.logger.should respond_to(:debug)
      Forkpool.logger.should respond_to(:error)
    end
  end

  describe ".on_child_start" do
    it "should accept a block and set the child start instance variable to that block" do
      to_change = "one"
      f = Forkpool.new(1)
      f.on_child_start do
        to_change = "two"
      end
      f.on_child_start_blk.call
      to_change.should == "two"
    end
  end

  describe ".on_child_exit" do
    it "should accept a block and set the child exit instance variable to that block" do
      to_change = "one"
      f = Forkpool.new(1)
      f.on_child_exit do
        to_change = "two"
      end
      f.on_child_exit_blk.call
      to_change.should == "two"
    end
  end

  describe ".start" do
    it "should spawn :max_forks processes" do
      FileUtils.rm("/tmp/fork_tests")
      f = Forkpool.new(5)
      Thread.new do
        f.start do
          test_file = File.new("/tmp/fork_tests", "a+")
          test_file.puts "anewline"
          test_file.close
          sleep 1
        end
      end
      f.stop
      sleep 1
      File.readlines("/tmp/fork_tests").size.should == 5
    end

    it "should set the @flag variable to :in_loop" do
      f = Forkpool.new(1)
      Thread.new do
        f.start do
          $0 = "forked"
          sleep 0.5
        end
      end
      sleep 1
      f.flag.should == :in_loop
      f.stop
    end

    it "should run the block passed to it in the children forks" do
      FileUtils.rm("/tmp/newf") if(File.exists?("/tmp/newf"))
      f = Forkpool.new(1)
      Thread.new do
        f.start do
          $0 = "forked"
          FileUtils.touch "/tmp/newf"
          sleep 3
        end
      end
      f.stop
      sleep 3
      File.exists?("/tmp/newf").should == true
    end
  end

  describe ".stop" do
    it "should set the @flag variable to :exit_loop" do
      f = Forkpool.new(1)
      Thread.new do
        f.start do
          $0 = "forked"
          sleep 0.5
        end
      end
      f.stop
      f.flag.should == :exit_loop
    end
  end

  describe ".terminate" do
    before(:each) do
      @fp = Forkpool.new(1)
      Thread.new do
        @fp.start do
          sleep 1
        end
      end
      sleep 1
    end

    after(:each) do
      @fp.stop
      @fp = nil
    end

    it "should raise an error if called while still in the loop" do
      lambda {@fp.terminate}.should raise_error(RuntimeError)
    end

    it "should close all IO connections" do
      @fp.stop
      Forkpool.children.each do |c|
        c.status.should == :close
      end
    end
  end

  describe ".interrupt" do
    it "should send the TERM signal to all childrens" do
      f = Forkpool.new(1)
      Thread.new do
        f.start do
          sleep 1
        end
      end
      sleep 0.5
      f.interrupt
      Process.waitall
      # sleep 4
      Forkpool.children.each do |c|
        `ps -o command,pid | grep #{c.pid} |grep -v grep`.should == ""
      end
    end
  end

  # tested via setting child process statuses
  describe ".make_child" do
  end

  describe ".child" do
    it "should execute the passed block" do
      blah = :one
      nil.expects(:syswrite).at_least(2)
      f = Forkpool.new(1)
      blk = Proc.new { blah = :two }
      f.send(:child, blk)
      blah.should == :two
    end
  end

  describe ".handle_signals" do
    it "should accept an array of signals to trap and.. trap them" do
      f = Forkpool.new(1)
      f.expects(:trap)
      f.send(:handle_signals, ["TERM"])
    end
  end
end
