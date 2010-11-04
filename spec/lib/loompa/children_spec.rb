require File.expand_path(File.join('..', '..', '/spec_helper.rb'), File.dirname(__FILE__))

describe "Children" do
  describe "#pids" do
    it "should print out the children's pids"
  end
  
  describe "#fds" do
    it "should return the children's IO instances"
  end
  
  describe "#active" do
    it "should return an array of active children"
  end
  
  describe "#idle" do
    it "should return an array of idle children"
  end
  
  describe "#by_fd" do
    it "should return a child instance, finding it by it's IO connection"
  end
  
  describe "#cleanup" do
    it "should create a new instance of Children with a new set of active children"
  end
end