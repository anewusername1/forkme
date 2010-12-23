require File.expand_path(File.join('..', '..', '/spec_helper.rb'), File.dirname(__FILE__))

describe "Forkpool" do
  describe "self.logger" do
    it "should have a logger with info, debug, and error methods" do
      f = Forkpool.new(1)
      Forkpool.logger.should respond_to(:info)
      Forkpool.logger.should respond_to(:debug)
      Forkpool.logger.should respond_to(:error)
    end
  end
  
  describe "#on_child_start" do
    it "should accept a block and set the child start instance variable to that block" do
      f = Forkpool.new(1)
      to_here, from_there = IO.pipe
      f.on_child_start do
        from_there.write "started_child"
        from_there.close
      end
      Thread.new do
        f.start do
          $0 = "forked"
          sleep 1
        end
      end
      f.stop
      from_there.close
      to_here.read.should == "started_child"
      to_here.close
    end
  end
  
  describe "#on_child_exit" do
    it "should accept a block and set the child exit instance variable to that block" do
      f = Forkpool.new(1)
      to_here, from_there = IO.pipe
      f.on_child_exit do
        from_there.write "exited_child"
        from_there.close
      end
      Thread.new do
        f.start do
          $0 = "forked"
        end
      end
      f.stop
      sleep 0.5
      from_there.close
      to_here.read.should == "exited_child"
      to_here.close
    end
  end
  
  describe "#start" do
    it "should spawn :max_forks processes"
    it "should set the @flag variable to :in_loop"
    it "should run the block passed to it in the children forks"
  end
  
  describe "#stop" do
    it "should set the @flag variable to :exit_loop"
  end
   
  describe "#terminate" do
    it "should raise an error if called while still in the loop"
    it "should close all IO connections"
  end
  
  describe "#interrupt" do
    it "should send the TERM signal to all childrens"
  end
  
  describe "#make_child" do
    it "should connect the child and parent processes together through IOs"
    it "should create a new child and execute the block"
  end
  
  describe "#child" do
    it "should create a new process and execute the passed block"
  end
  
  describe "#handle_signals" do
    it "should accept an array of signals to trap and.. trap them"
  end
end