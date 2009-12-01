module StaleFish

  class FixtureDefinition
    attr_accessor :tag, :file_path, :source_url, :last_updated_at, :response
    attr_accessor :update_frequency

    def is_stale?
      StaleFish.force_flag || last_updated_at.nil? || ((DateTime.now + eval(update_frequency)) < last_updated_at)
    end

    def update!
      begin
        self.response = StaleFish.http.resource(source_url).get
        File.open(file_path, 'w') { |file| file.write(response.body.to_s) }
        self.last_updated_at = DateTime.now
      rescue Resourceful::UnsuccessfulHttpRequestError
        raise StaleFish::FixtureUpdateFailure, "#{tag}'s source: #{source_url} returned unsuccessfully."
      rescue ArgumentError
        raise StaleFish::MalformedSourceURL, "#{tag}'s source: #{source_url} is not a valid URL path. Most likely it's missing a trailing slash."
      end
    end

    def output_hash
<<-EOF
  #{tag}:
    file_path: #{file_path}
    source_url: #{source_url}
    update_frequency: #{update_frequency}
    last_updated_at: #{last_updated_at}
EOF
    end
  end

end
