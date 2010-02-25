require 'activesupport'

module StaleFish
  class Fixture
    attr_accessor :name, :file, :last_updated_at
    attr_accessor :update_interval
    attr_accessor :check_against, :request_type
    attr_accessor :update_method

    def initialize(attributes={})
      attributes.each do |key, value|
        self.send("#{key}=", value)
      end
    end

    def is_stale?
      if last_updated_at.nil? || (last_updated_at + eval(update_interval)) < DateTime.now
        return true
      else
        return false
      end
    end

    def update!
      response = if update_method
                   update_by_method
                 else
                   update_by_network
                 end
      write_response_to_file(response)
      self.last_updated_at = DateTime.now
    end
    
    def update_by_method
      return eval(update_method)
    end

    def update_by_network
      uri, type = URI.parse(check_against), request_type.downcase.to_sym
      Net::HTTP.start(uri.host) do |http|
        response = if type == :post
                     http.post(uri.path)
                   else
                     http.get(uri.path)
                   end
        return response.body
      end
    end

    def register_lock!
      uri, type = build_uri, request_type.downcase.to_sym
      FakeWeb.register_uri(type, uri, :body => File.join(File.dirname(StaleFish.configuration), file))

      return FakeWeb.registered_uri?(type, uri)
    end

    def to_yaml
      # update_interval.inspect trick is to prevent Fixnum being written
      yaml = ""
      yaml << <<-EOF
  #{name}:
    file: '#{file}'
    update_interval: #{update_interval.inspect.gsub(/ /, '.').gsub(/"/, '')}
    check_against: #{check_against}
    request_type: #{request_type}
EOF
    if update_method
      yaml << <<-EOF
    update_method: #{update_method}
EOF
    end
    
    yaml << <<-EOF
    last_updated_at: #{last_updated_at}
EOF
      return yaml
    end
    
    def last_updated_at
      if @last_updated_at.nil? || @last_updated_at.is_a?(DateTime)
        @last_updated_at
      else
        DateTime.parse(@last_updated_at.to_s)
      end
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
        File.open(File.join(File.dirname(StaleFish.configuration), file), "w") { |file| file.write(body) }
      end
  end
end
