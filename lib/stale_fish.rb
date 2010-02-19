require 'active_support/core_ext/numeric/time'
require 'fakeweb'
require 'yaml'

require 'stale_fish/fixture'

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
    end

    def update_stale!(options={})
      # this is with force
    end

    protected

      def load
        yaml = YAML::load(File.open(configuration)).symbolize_keys!
      end
  end
end
