require File.join(File.dirname(__FILE__), *%w[.. spec_helper])

describe StaleFish do

  context ".configuration" do
    it "should return a default path" do
      StaleFish.configuration.should == 'stale_fish.yml'
    end
  end

  context ".configuration=" do
    it "should assign the path to the config file" do
      StaleFish.configuration = '/someplace/stale_fish.yml'
      StaleFish.configuration.should == '/someplace/stale_fish.yml'
    end
  end

  context ".load" do
    before do
      test_yaml = File.join(File.dirname(__FILE__), '..', 'support', 'test.yml')
      StaleFish.stub!(:configuration).and_return(test_yaml)
      StaleFish::Fixture.should_receive(:new).at_least(:once)
    end

    it "should build fixtures"
  end

  context ".update_stale" do
    it "should have real tests"
  end

  context ".update_stale!" do
    it "should have real tests"
  end
end
