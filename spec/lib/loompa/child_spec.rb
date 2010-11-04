require File.expand_path(File.join('..', '..', '/spec_helper.rb'), File.dirname(__FILE__))

describe "Child" do
  before(:each) do
    pipe = IO.pipe
    to = flexmock(pipe[0], {'closed?' => false, :close => true})
    from = flexmock(pipe[0], {'closed?' => false, :close => true})
    @c = Child.new(5000, from, to)
  end
  
  it "should create a new instance being in idle status" do
    @c.status.should == :idle
  end
  
  describe "#event" do
    it "should receive an event :connect and change it's status to :connect" do
      @c.event("connect").should == :connect
    end
    
    it "should receive an event :disconnect and change it's status to :idle" do
      @c.event("disconnect").should == :idle
    end
    
    it "should receive an event nil and exit" do
      @c.event(nil).should == :exit
    end
    
    it "should receive a non-sensicle event and return an error message" do
      flexmock(Loompa.logger, {:error => "unknown status: non-sensicle"})
      @c.event("non-sensicle").should == "unknown status: non-sensicle"
    end
  end
  
  describe "#close" do
    it "should change the status to close and close the IO object" do
      # @c.to.should_receive(:closed?).and_return(false)
      @c.status.should == :close
    end
  end
  
  describe "#exit" do
    it "should close the from IO"
    it "should close the to IO"
    it "should set its status to :exit"
  end
  
  describe "#idle?" do
    it "should return true if it's in :idle status"
    it "should return false if it's not in :idle status"
  end
  
  describe "#active?" do
    it "should return true if its status is either :idle or :connect"
    it "should return false it its status is neither :idle nor :connect"
  end
  
end
  