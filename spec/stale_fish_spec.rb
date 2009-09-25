require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "StaleFish" do

  before do
    @valid_yaml = File.dirname(__FILE__) + "/fixtures/stale_fish.yml"
  end

  it "should assign the config file" do
    StaleFish::Utility.config_path = @valid_yaml
    StaleFish::Utility.config_path.should == @valid_yaml
    StaleFish::Utility.valid_path?.should == true
  end

  context "when loading the yaml file" do

    it "should raise errors on malformed yaml" do
      StaleFish::Utility.config_path = File.dirname(__FILE__) + "/fixtures/malformed_stale_fish.yml"
      lambda { StaleFish::Utility.loader }.should_not raise_error(Errno::ENOENT)
      lambda { StaleFish::Utility.loader }.should raise_error(YAML::Error)
    end

    it "shouldn't fail on valid yaml" do
      StaleFish::Utility.config_path = @valid_yaml
      lambda { StaleFish::Utility.loader }.should_not raise_error(YAML::Error)
    end

    it "should establish the fixture definitions" do
      StaleFish::Utility.config_path = @valid_yaml
      lambda { StaleFish::Utility.loader }
    end

  end

  context "after loading the config" do

    before(:each) do
      FileUtils.cp(@valid_yaml, File.dirname(__FILE__) + "/fixtures/stale_fish.orig.yml")
      StaleFish::Utility.config_path = @valid_yaml
      StaleFish::Utility.valid_path?.should == true
      StaleFish::Utility.loader
    end

    it "should update all stale fixtures" do
      StaleFish.update_stale.should == 2
    end

    it "should update only the passed fixtures, if stale" do
      StaleFish.update_stale('google').should == 1
    end

    it "should update all passed fixtures, when passed the :force flag" do
      StaleFish.update_stale('google').should == 1
      StaleFish.update_stale('google', :force => true).should == 1
    end

    it "should not have any remaining fixtures to update" do
      StaleFish.update_stale.should == 2
      StaleFish.fixtures = []           # this will force a reload of the YAML file.
      StaleFish.fixtures.should == []   # ensure it was reset
      StaleFish::Utility.loader
      StaleFish.update_stale.should == 0
    end

    it "should notify user, and rollback, if source is no longer valid"

    after(:each) do
      FileUtils.mv(@valid_yaml, File.dirname(__FILE__)+"/../tmp/stale_fish.test.yml")
      FileUtils.mv(File.dirname(__FILE__)+"/fixtures/stale_fish.orig.yml", @valid_yaml)
      StaleFish.fixtures = []
    end

  end

  context "with FakeWeb" do

    before(:each) do
      @fakeweb_yaml = File.dirname(__FILE__) + '/fixtures/stale_fish_fakeweb.yml'
      StaleFish::Utility.config_path = @fakeweb_yaml
      StaleFish::Utility.valid_path?.should == true
      StaleFish::Utility.loader
      StaleFish.use_fakeweb = true
      StaleFish.use_fakeweb.should == true
    end

    it "should register any FakeWeb URI's" do
      definition = StaleFish.fixtures.first
      definition.register_uri
      FakeWeb.registered_uri?(definition.source_url).should == true
    end

    it "should turn off FakeWeb.allow_net_connect to process stale fixtures" do
      FakeWeb.allow_net_connect = false
      lambda { StaleFish.update_stale(:force => true) }.should_not raise_error
      lambda { StaleFish.update_stale(:force => true) }.should_not change { FakeWeb.allow_net_connect? }
    end

    after(:each) do
      StaleFish.fixtures = []
    end

  end

end
