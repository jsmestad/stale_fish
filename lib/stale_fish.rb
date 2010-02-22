#Rails 3: require 'active_support/core_ext/numeric/time'
require 'active_support'
require 'fakeweb'
require 'yaml'

require File.join(File.dirname(__FILE__), 'stale_fish', 'fixture')

module StaleFish
  # no one likes stale fish.
  class << self

    def setup(config_location=nil)
      self.configuration = config_location
      load
      register_fixtures
      block_requests
    end

    def configuration=(config)
      @configuration = config
    end

    def configuration
      @configuration || if defined?(Rails)
                          File.join(Rails.root, 'spec', 'stale_fish.yml')
                        else
                          'stale_fish.yml'
                        end
    end

    def update_stale(options={})
      reset_fixtures = false
      
      allow_requests
      fixtures(options).each do |fixture|
        if fixture.is_stale?
          fixture.update!
          reset_fixtures = true
        end
      end
      register_fixtures if reset_fixtures
      block_requests
      write
    end

    def update_stale!(options={})
      allow_requests
      fixtures(options).each do |fixture|
        fixture.update!
      end
      register_fixtures
      block_requests
      write
    end

    def fixtures(params=nil)
      @fixtures ||= []
      if params.is_a?(Hash)
        if params[:only]
          @fixtures.select { |f| params[:only].include?(f.name.to_sym) }
        elsif params[:except]
          @fixtures.select { |f| !params[:except].include?(f.name.to_sym) }
        end
      else
        @fixtures
      end
    end

    protected

      def load
        @fixtures = []
        definitions = YAML::load(File.open(configuration))['stale'].symbolize_keys!
        definitions.each do |key, definition|
          self.fixtures << StaleFish::Fixture.new(definition.merge({:name => key.to_s}))
        end
        return fixtures
      end

      def write
        updated_yaml = []
        fixtures.each do |fixture|
          updated_yaml << fixture.to_yaml
        end
        updated_yaml = { :stale => updated_yaml }
        File.open(configuration, 'w') { |file| updated_yaml.to_yaml }
      end

      def allow_requests
        FakeWeb.allow_net_connect = true
      end

      def block_requests
        FakeWeb.allow_net_connect = false
      end

      def register_fixtures
        FakeWeb.clean_registry
        fixtures.each do |fixture|
          fixture.register_lock!
        end
      end
  end
end
