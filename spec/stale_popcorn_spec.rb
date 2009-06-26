require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "StalePopcorn" do
  
  it "should assign the config file" do
    StalePopcorn.config_path = File.dirname(__FILE__) + "/fixtures/stale_popcorn.yml"
    StalePopcorn.config_path.should == File.dirname(__FILE__) + "/fixtures/stale_popcorn.yml"
    StalePopcorn.valid_path?.should == true
  end

  context "when loading the yaml file" do
    it "should raise errors on malformed yaml" do
      StalePopcorn.config_path = File.dirname(__FILE__) + "/fixtures/malformed_stale_popcorn.yml"
      lambda { StalePopcorn.load_yaml }.should_not raise_error(Errno::ENOENT)
      lambda { StalePopcorn.load_yaml }.should raise_error(YAML::Error)
    end

    it "should pass on valid yaml" do
      StalePopcorn.config_path = File.dirname(__FILE__) + "/fixtures/stale_popcorn.yml"
      lambda { StalePopcorn.load_yaml }.should_not raise_error(YAML::Error)
    end
  end

  context "after loading the config" do
    before do
      FileUtils.cp(File.dirname(__FILE__)+"/fixtures/stale_popcorn.yml", File.dirname(__FILE__)+"/fixtures/stale_popcorn.orig.yml")
      StalePopcorn.config_path = File.dirname(__FILE__) + "/fixtures/stale_popcorn.yml"
      StalePopcorn.valid_path?.should == true
    end

    it "should update all stale fixtures" do
      StalePopcorn.update_stale.should == true
    end

    #it "should update only the passed fixtures, if stale"
    #it "should update all passed fixtures, when passed the :force flag"
    #it "should notify user, and rollback, if source is no longer valid"

    after do
      FileUtils.mv(File.dirname(__FILE__)+"/fixtures/stale_popcorn.yml", File.dirname(__FILE__)+"/../tmp/stale_popcorn.test.yml")
      FileUtils.mv(File.dirname(__FILE__)+"/fixtures/stale_popcorn.orig.yml", File.dirname(__FILE__)+"/fixtures/stale_popcorn.yml")      
    end
  end
end
