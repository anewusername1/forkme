require File.expand_path(File.join('..', '..', '/spec_helper.rb'), File.dirname(__FILE__))

describe "Children" do
  before(:each) do
    pipe = IO.pipe
    @to = pipe[0]
    @from = pipe[1]
    @c = Child.new(5000, @from, @to)
    @childrens = Children.new
    @childrens << @c
  end
  
  describe "#pids" do
    it "should print out the children's pids" do
      @childrens.pids.should == [5000]
    end
  end
  
  describe "#fds" do
    it "should return the children's IO instances" do
      @childrens.fds.class.should == Array
      @childrens.fds.first.should == @c.from
    end
  end
  
  describe "#active" do
    it "should return an array of active children" do
      @childrens.active.should == [@c]
    end
  end
  
  describe "#idle" do
    it "should return an array of idle children" do
      @c.event("disconnect")
      @childrens.idle.should == [@c]
    end
  end
  
  describe "#by_fd" do
    it "should return a child instance, finding it by it's IO connection" do
      @childrens.by_fd(@from).should == @c
    end
  end
  
  describe "#cleanup" do
    it "should create a new instance of Children with a new set of active children" do
      pipe_1 = IO.pipe
      pipe_2 = IO.pipe
      
      c1 = Child.new(5001, pipe_1[0], pipe_1[1])
      c2 = Child.new(5002, pipe_2[0], pipe_2[1])
      childs = Children.new
      childs << c1
      childs << c2

      childs.active.length.should == 2
      c1.exit
      childs.active.length.should == 1
    end
  end
end