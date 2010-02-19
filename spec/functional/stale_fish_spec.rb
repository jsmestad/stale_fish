require File.join(File.dirname(__FILE__), *%w[.. spec_helper])

describe StaleFish do
  context ".update_stale" do
    before do
      # StaleFish.stub!(:config_path).and_return('dude.yml')
      # use support/stale_fish.yml
    end

    it "should only update outdated fixtures"

    context "if applicable," do
      it "should update all fixtures when :all is passed"

      it "should update only passed fixtures when :only is passed"

      it "should update all fixtures except passsed when :except is passed"
    end
  end

  context ".update_stale!" do
    it "should force update regardless of timestamp"
  end
end
