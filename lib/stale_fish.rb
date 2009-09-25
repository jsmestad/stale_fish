require 'singleton'
require 'ftools'
require 'yaml'
require 'rubygems'
require 'activesupport' # only used for time helpers
require 'resourceful'

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
  self.http = Resourceful::HttpAccessor.new

  def self.update_stale(*args)
    # TODO move this to its own spot
    self.force_flag = args.pop[:force] if args.last.is_a?(Hash)

    # check each file for update
    Utility.loader if self.fixtures.empty?
    if args.empty?
      stale = fixtures.select { |f| f.is_stale? }
      fixtures.each do |fixture|
        fixture.update! if fixture.is_stale?
        fixture.register_uri if StaleFish.use_fakeweb
      end
    else
      stale = fixtures.select { |f| f.is_stale? && args.include?(f.tag) }
      fixtures.each do |fixture|
        if args.include?(fixture.tag)
          fixture.update! if fixture.is_stale?
          fixture.register_uri if StaleFish.use_fakeweb
        end
      end
    end
    Utility.writer
    return stale.size
  end

end
