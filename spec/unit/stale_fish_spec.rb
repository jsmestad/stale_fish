require File.join(File.dirname(__FILE__), *%w[.. spec_helper])

describe StaleFish do
  before do
    @stale_fixture = StaleFish::Fixture.new(:last_updated_at => 1.week.ago.to_datetime,
                                            :update_interval => '1.day',
                                            :request_type => 'GET',
                                            :check_against => 'http://google.com/index.html')
    @fresh_fixture = StaleFish::Fixture.new(:last_updated_at => 1.day.from_now.to_datetime,
                                            :update_interval => '1.day',
                                            :request_type => 'GET',
                                            :check_against => 'http://google.com/index.html')
  end

  context ".setup" do
    it "should call appropriate functions" do
      StaleFish.should_receive(:load)
      StaleFish.should_receive(:block_requests)
      StaleFish.setup
    end
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
      @stale_fixture.stub!(:update!).and_return(true)
      @fresh_fixture.stub!(:update!).and_return(true)
      StaleFish.should_receive(:write)
    end

    it "should only call update! on stale fixtures" do
      @stale_fixture.should_receive(:update!).once
      @fresh_fixture.should_not_receive(:update!)
      StaleFish.update_stale
    end

    it "should block requests after completion" do
      StaleFish.should_receive(:allow_requests)
      StaleFish.should_receive(:block_requests)
      StaleFish.update_stale
    end
  end

  context ".update_stale!" do
    before do
      StaleFish.stub!(:fixtures).and_return([@stale_fixture,@fresh_fixture])
      @stale_fixture.stub!(:update!).and_return(true)
      @fresh_fixture.stub!(:update!).and_return(true)
      StaleFish.should_receive(:write)
    end

    it "should only call update! on all fixtures" do
      @stale_fixture.should_receive(:update!).once
      @fresh_fixture.should_receive(:update!).once
      StaleFish.update_stale!
    end

    it "should block requests after completion" do
      StaleFish.should_receive(:allow_requests)
      StaleFish.should_receive(:block_requests)
      StaleFish.update_stale!
    end
  end

  context ".fixtures" do
    before do
      StaleFish.fixtures.size.should == 2
    end

    it "should accept the :all parameter" do
      StaleFish.fixtures(:all).size == 2
    end

    it "should accept the :only parameter with an array of symbols" do
      response = StaleFish.fixtures(:only => [:twitter])
      response.size.should == 1
      response.first.name.should == 'twitter'
    end

    it "should accept the :except parameter with an array of symbols" do
      response = StaleFish.fixtures(:except => [:twitter])
      response.size.should == 1
      response.first.name.should_not == 'twitter'
    end

  end

  context ".write" do
    before do
      StaleFish.stub!(:fixtures).and_return([@stale_fixture,@fresh_fixture])
      File.should_receive(:open).and_return(true)
    end

    it "should overwrite the contents of the YAML file" do
      StaleFish.send(:write)
    end
  end

  context ".allow_requests" do
    it "should disable FakeWeb" do
      StaleFish.send(:allow_requests).should == true
    end
  end

  context ".block_requests" do
    it "should disable FakeWeb" do
      StaleFish.send(:block_requests).should == false
    end
  end
end
