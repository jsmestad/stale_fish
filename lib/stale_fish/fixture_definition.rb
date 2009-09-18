module StaleFish
  class FixtureDefinition
    attr_accessor :file_path, :source_url, :update_frequency, :last_updated_at

    def is_stale?
      # TODO Need to handle :force flag here. ::StaleFish.force_flag
      @stale ||= last_updated_at.nil? || (DateTime.now + update_frequency) > last_updated_at
    end

  end
end
