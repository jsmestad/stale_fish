require File.join(File.dirname(__FILE__), *%w[.. spec_helper])

describe StaleFish::Fixture do
  context "#initialize" do
    it "set the proper arguements"
  end

  context "#stale?" do
    it "should return true when stale"
    it "should return false when fresh"
  end

  context "#update!" do
    it "should update the fixture data"
  end

  context "#to_yaml" do
    it "should have the proper schema"
  end
end
