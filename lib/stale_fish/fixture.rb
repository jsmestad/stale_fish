module StaleFish
  class Fixture
    attr_accessor :name, :file, :last_updated_at
    attr_accessor :update_interval, :check_against, :request_type

    def initialize(attributes={})
      attributes.each do |key, value|
        self.send("#{key}=", value)
      end
    end

    def is_stale?
      if last_updated_at + update_interval < Time.now
        return true
      else
        return false
      end
    end

    def update!
      # update fixture
    end

    def to_yaml
      # convert obj to stale_fish yaml
      # NOTE: ORDER MATTERS WHEN WRITING
    end
  end
end
