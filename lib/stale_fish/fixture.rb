module StaleFish
  class Fixture
    attr_accessor :name, :file, :last_updated_at
    attr_accessor :update_interval, :update_string, :check_against, :request_type

    def initialize(attributes={})
      attributes.each do |key, value|
        self.send("#{key}=", value)
      end
    end

    def is_stale?
      if last_updated_at.nil? || (DateTime.parse(last_updated_at) + update_interval) < DateTime.now
        return true
      else
        return false
      end
    end

    def update!
      uri, type = URI.parse(check_against), request_type.downcase.to_sym
      Net::HTTP.start(uri.host) do |http|
        response = if type == :post
                     http.post(uri.path)
                   else
                     http.get(uri.path)
                   end
        write_response_to_file(response.body)
      end

      self.last_updated_at = Time.now
    end

    def register_lock!
      uri, type = build_uri, request_type.downcase.to_sym
      FakeWeb.register_uri(type, uri, :body => file)

      return FakeWeb.registered_uri?(type, uri)
    end

    def to_yaml
      # update_interval.inspect trick is to prevent Fixnum being written
      yaml = <<-EOF
#{name}:
  file: '#{file}'
  update_interval: #{update_interval.inspect.gsub(/ /, '.')}
  check_against: #{check_against}
  request_type: #{request_type}
  last_updated_at: #{last_updated_at}
EOF
      return yaml
    end

    protected

      def build_uri
        if check_against =~ /:\d+/
          Regexp.new(check_against, true)
        else
          check_against
        end
      end

      def write_response_to_file(body)
        File.open(file, "w") { |file| file.write(body) }
      end
  end
end
