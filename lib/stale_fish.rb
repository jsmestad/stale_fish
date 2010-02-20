#require 'active_support/core_ext/numeric/time'
require 'active_support'
require 'fakeweb'
require 'yaml'

require File.join(File.dirname(__FILE__), 'stale_fish', 'fixture')

module StaleFish
  # no one likes stale fish.
  class << self

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
      # this is without force
      fixtures.each do |fixture|
        if fixture.is_stale?
          fixture.update!
        end
      end
    end

    def update_stale!(options={})
      # forced update regardless
      fixtures.each do |fixture|
        fixture.update!
      end
    end

    def fixtures
      @fixtures ||= []
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

  end
end
