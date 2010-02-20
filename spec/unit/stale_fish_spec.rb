require File.join(File.dirname(__FILE__), *%w[.. spec_helper])

describe StaleFish do
  before do
    @stale_fixture = StaleFish::Fixture.new(:last_updated_at => 1.week.ago,
                                            :update_interval => 1.day)
    @fresh_fixture = StaleFish::Fixture.new(:last_updated_at => 1.day.from_now,
                                            :update_interval => 1.day)
  end

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
    end

    it "should build fixtures" do
      StaleFish.send(:load).size.should == 2
      StaleFish.fixtures.size.should == 2
    end

  end

  context ".update_stale" do
    before do
      StaleFish.stub!(:fixtures).and_return([@stale_fixture,@fresh_fixture])
    end

    it "should only call update! on stale fixtures" do
      @stale_fixture.should_receive(:update!).once
      @fresh_fixture.should_not_receive(:update!)
      StaleFish.update_stale
    end
  end

  context ".update_stale!" do
    before do
      StaleFish.stub!(:fixtures).and_return([@stale_fixture,@fresh_fixture])
    end

    it "should only call update! on all fixtures" do
      @stale_fixture.should_receive(:update!).once
      @fresh_fixture.should_receive(:update!).once
      StaleFish.update_stale!
    end
  end
end
