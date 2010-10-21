require "spec_helper.rb"

describe "Child" do
  
  it "should create a new instance being in idle status"
  
  describe "#event" do
    it "should receive an event :connect and change it's status to :connect"
    it "should receive an event :disconnect and change it's status to :idle"
    it "should receive an event nil and exit"
    it "should receive a non-sensicle event and return an error message"
  end
  
  describe "#close" do
    it "should change the status to close and close the IO object"
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
  