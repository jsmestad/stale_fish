require 'singleton'
require 'ftools'
require 'yaml'
require 'rubygems'
require 'activesupport' # only used for time helpers

require 'stale_fish/utility'
require 'stale_fish/fixture_definition'

begin
  require 'fakeweb'
  require 'stale_fish/fakeweb'
rescue LoadError; end

module StaleFish
  # no one likes stale fish.

  class FixtureUpdateFailure < StandardError; end
  class MalformedSourceURL < StandardError;  end

  class << self
    attr_accessor :configuration
    attr_accessor :http
    attr_accessor :fixtures
    attr_accessor :force_flag
  end

  self.fixtures = []
  Utility.config_path = 'stale_fish.yml'

  def self.update_stale(*args)
    # TODO move this to its own spot
    Utility.loader if self.fixtures.empty?
    self.force_flag = args.pop[:force] if args.last.is_a?(Hash)

    stale = if args.empty?
              fixtures.select { |f| f.is_stale? }
            else
              fixtures.select { |f| f.is_stale? && args.include?(f.tag) }
            end

    stale.each do |fixture|
      fixture.update!
    end

    fixtures.each { |fixture| fixture.register_uri if StaleFish.use_fakeweb }

    Utility.writer
    return stale.size
  end

end
