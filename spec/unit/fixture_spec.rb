require File.join(File.dirname(__FILE__), *%w[.. spec_helper])

describe StaleFish::Fixture do
  before do
    @time = Time.now
    @args = {
      :name => 'commits',
      :file => 'commit.json',
      :last_updated_at => @time,
      :update_interval => 2.days,
      :check_against => 'http://google.com',
      :request_type => 'GET'
    }
  end

  context "#initialize" do
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
    
    it "should return true when last_updated_at is empty" do
      @stale_fixture.last_updated_at = nil
      @stale_fixture.is_stale?.should == true
    end
  end

  context "#update!" do
    before do
      @fixture = StaleFish::Fixture.new(:request_type => 'GET',
                                        :check_against => 'http://google.com/index.html',
                                        :file => 'index.html')
    end

    it "should update the fixture data" do
      @fixture.should_receive(:write_response_to_file).once.and_return(true)
      @fixture.update!
      @fixture.last_updated_at.should be_a(Time)
    end

    it "should use Net::HTTP#get with a GET request_type"
    it "should use Net::HTTP#post with a POST request_type"
  end

  context "#register_lock!" do
    before do
      @fixture = StaleFish::Fixture.new(:request_type => 'GET',
                                        :check_against => 'http://google.com/index.html',
                                        :file => 'index.html')
    end

    it "should add fakeweb register_uri" do
      @fixture.register_lock!.should == true
    end
  end

  context "#to_yaml" do
    before do
      @fixture = StaleFish::Fixture.new(:name => 'google',
                                        :update_interval => 1.day,
                                        :request_type => 'GET',
                                        :check_against => 'http://google.com/index.html',
                                        :file => 'index.html',
                                        :last_updated_at => @time)
      @proper_yaml =
<<-EOF
google:
  file: 'index.html'
  update_interval: 1.day
  check_against: http://google.com/index.html
  request_type: GET
  last_updated_at: #{@time}
EOF
    end

    it "should have the proper schema" do
      @fixture.to_yaml.should == @proper_yaml
    end
  end

  context "#build_uri" do
    before do
      @fixture = StaleFish::Fixture.new(@args)
    end

    it "should parse anything with a port as a regular expression" do
      @fixture.check_against = 'http://www.google.com:443/index.html'
      @fixture.send(:build_uri).should be_a(Regexp)
    end

    it "should parse anything without a port as a string" do
      @fixture.check_against = 'http://www.google.com/index.html'
      @fixture.send(:build_uri).should be_a(String)
    end
  end

  context "#write_response_to_file" do
    before do
      @fixture = StaleFish::Fixture.new(@args)
    end

    it "should update the passed in file" do
      File.should_receive(:open).and_return(true)
      @fixture.send(:write_response_to_file, 'this is a response')
    end

    it "should have failover with a bad response"
  end
end
