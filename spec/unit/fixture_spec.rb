require File.join(File.dirname(__FILE__), *%w[.. spec_helper])

describe StaleFish::Fixture do
  context "#initialize" do
    before do
      @args = {
        :name => 'commits',
        :file => 'commit.json',
        :last_updated_at => Time.now,
        :update_interval => 2.days,
        :check_against => 'http://google.com',
        :request_type => 'GET'
      }
    end

    it "set the proper arguements" do
      fixture = StaleFish::Fixture.new(@args)
      @args.each do |key, value|
        fixture.send(key).should == value
      end
    end
  end

  context "#is_stale?" do
    before do
      @stale_fixture = StaleFish::Fixture.new(:last_updated_at => 1.week.ago,
                                              :update_interval => 1.day)
      @fresh_fixture = StaleFish::Fixture.new(:last_updated_at => 1.day.from_now,
                                              :update_interval => 1.day)
    end

    it "should return true when stale" do
      @stale_fixture.is_stale?.should == true
    end

    it "should return false when fresh" do
      @fresh_fixture.is_stale?.should == false
    end
  end

  context "#update!" do
    it "should update the fixture data"
  end

  context "#to_yaml" do
    it "should have the proper schema"
  end
end
