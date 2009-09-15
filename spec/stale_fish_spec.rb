require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "StaleFish" do
  before do
    @valid_yaml = File.dirname(__FILE__) + "/fixtures/stale_fish.yml"
  end

  it "should assign the config file" do
    StaleFish.config_path = @valid_yaml
    StaleFish.config_path.should == @valid_yaml
    StaleFish.valid_path?.should == true
  end

  context "when loading the yaml file" do
    it "should raise errors on malformed yaml" do
      StaleFish.config_path = File.dirname(__FILE__) + "/fixtures/malformed_stale_fish.yml"
      lambda { StaleFish.load_yaml }.should_not raise_error(Errno::ENOENT)
      lambda { StaleFish.load_yaml }.should raise_error(YAML::Error)
    end

    it "should pass on valid yaml" do
      StaleFish.config_path = @valid_yaml
      lambda { StaleFish.load_yaml }.should_not raise_error(YAML::Error)
    end

  end

  context "after loading the config" do
    before(:each) do
      FileUtils.cp(@valid_yaml, File.dirname(__FILE__)+"/fixtures/stale_fish.orig.yml")
      StaleFish.config_path = @valid_yaml
      StaleFish.valid_path?.should == true
      StaleFish.load_yaml
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
      StaleFish.yaml = nil           # this will force a reload of the YAML file.
      StaleFish.yaml.should == nil   # ensure it was reset
      StaleFish.load_yaml
      StaleFish.update_stale.should == 0
    end

    it "should notify user, and rollback, if source is no longer valid"

    after(:each) do
      FileUtils.mv(@valid_yaml, File.dirname(__FILE__)+"/../tmp/stale_fish.test.yml")
      FileUtils.mv(File.dirname(__FILE__)+"/fixtures/stale_fish.orig.yml", @valid_yaml)
      StaleFish.yaml = nil
    end
  end

  context "with FakeWeb" do
    before(:each) do
      @fakeweb_yaml = File.dirname(__FILE__) + '/fixtures/stale_fish_fakeweb.yml'
      StaleFish.config_path = @fakeweb_yaml
      StaleFish.valid_path?.should == true
      StaleFish.load_yaml
      StaleFish.use_fakeweb = true
      StaleFish.use_fakeweb.should == true
    end

    it "should register any FakeWeb URI's" do
      StaleFish.register_uri("http://www.google.com", "some shit")
      FakeWeb.registered_uri?("http://www.google.com").should == true
    end

    it "should turn off FakeWeb.allow_net_connect to process stale fixtures" do
      FakeWeb.allow_net_connect = false
      lambda { StaleFish.update_stale(:force => true) }.should_not raise_error
      lambda { StaleFish.update_stale(:force => true) }.should_not change { FakeWeb.allow_net_connect? }
    end

    after(:each) do
      StaleFish.yaml = nil
    end
  end

end
