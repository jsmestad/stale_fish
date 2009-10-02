module StaleFish

  class << self
    attr_accessor :use_fakeweb
  end

  self.use_fakeweb = true

  class FixtureDefinition
    alias_method :update_without_fakeweb, :update!

    def update!
      FakeWeb.allow_net_connect = true
      update_without_fakeweb
      FakeWeb.allow_net_connect = false
    end

    def register_uri
      if StaleFish.use_fakeweb && !FakeWeb.registered_uri?(:any, source_url)
        FakeWeb.register_uri(:any, source_url, :body => file_path)
      end
    end

  end

end
