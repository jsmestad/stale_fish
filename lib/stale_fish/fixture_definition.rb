module StaleFish

  class FixtureDefinition
    attr_accessor :tag, :file_path, :source_url, :last_updated_at, :response
    attr_accessor :update_frequency

    def is_stale?
      StaleFish.force_flag || last_updated_at.nil? || ((DateTime.now + update_frequency) > last_updated_at)
    end

    def update!
      begin
        self.response = StaleFish.http.resource(source_url).get
        File.open(file_path, 'w') { |file| file.write(response.body.to_s) }
        self.last_updated_at = DateTime.now
      rescue Resourceful::UnsuccessfulHttpRequestError
        raise StaleFish::FixtureUpdateFailure, "#{key}'s source: #{value['source']} returned unsuccessfully."
      rescue ArgumentError
        raise StaleFish::MalformedSourceURL, "#{key}'s source: #{value['source']} is not a valid URL path. Most likely it's missing a trailing slash."
      end
    end

  end

end
