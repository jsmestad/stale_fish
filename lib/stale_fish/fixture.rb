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
      if (last_updated_at + update_interval) < Time.now
        return true
      else
        return false
      end
    end

    def update!
      # update fixture
      # needs to disengage FakeWeb before, and return state after
      uri, type = URI.parse(check_against), request_type.downcase.to_sym
      Net::HTTP.start(uri.host) { |http|
        response = if type == :post
                 http.post(uri.path, uri.query)
               else
                 http.get(uri.path)
               end
        write_response_to_file(response)
      }

      self.last_updated_at = Time.now
    end

    def register_lock!
      uri, type = build_uri, request_type.downcase.to_sym
      FakeWeb.register_uri(type, uri, :body => file)

      return FakeWeb.registered_uri?(type, uri)
    end

    def to_yaml
      # convert obj to stale_fish yaml
      # NOTE: ORDER MATTERS WHEN WRITING
    end

    protected

      def build_uri
        if check_against =~ /:\d+/
          Regexp.new(check_against, true)
        else
          check_against
        end
      end

      def write_response_to_file(response)
        File.open(file, "w") { |file| file.write(response.body) }
      end
  end
end
