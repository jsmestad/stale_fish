require File.dirname(__FILE__) + '/spec_helper'

describe StaleFish do

  before do
    @deprecated_yaml = File.dirname(__FILE__) + "/fixtures/deprecated_yaml.yml"
  end

  it "should assign the config file" do
    StaleFish::Utility.config_path = @deprecated_yaml
    StaleFish::Utility.config_path.should == @deprecated_yaml
    StaleFish::Utility.valid_path?.should == true
  end

  it "should map to valid attributes" do
    pending
    StaleFish::Utility.loader
  end

end
