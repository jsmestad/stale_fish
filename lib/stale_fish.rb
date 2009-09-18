require 'singleton'
require 'ftools'
require 'yaml'
require 'rubygems'
require 'activesupport' # only used for time helpers
require 'resourceful'
begin
  require "fakeweb"
rescue LoadError

end

require 'stale_fish/utility'
require 'stale_fish/fixture_definition'

module StaleFish
  # no one likes stale fish.

  class FixtureUpdateFailure < StandardError; end
  class MalformedSourceURL < StandardError;  end

  class << self
    attr_accessor :use_fakeweb
    attr_accessor :config_path
    attr_accessor :yaml
    attr_accessor :configuration
    attr_accessor :http
    attr_accessor :fixtures
  end

  self.fixtures = []
  self.use_fakeweb = false
  Utility.config_path = 'stale_fish.yml'
  self.http = Resourceful::HttpAccessor.new

  def self.update_stale(*args)
    # check each file for update
    Utility.loader if self.yaml.nil?
    stale = flag_stale(args)
    process(stale)
    write_yaml
    return stale.size
  end

  def self.register_uri(source_uri, response)
    FakeWeb.register_uri(:any, source_uri, :body => response) if use_fakeweb && !FakeWeb.registered_uri?(source_uri)
  end

  def self.load_yaml
    raise Errno::ENOENT, 'invalid path, please set StaleFish.config_path than ensure StaleFish.valid_path? is true' unless valid_path?

    self.yaml = YAML.load_file(config_path)
    raise YAML::Error, 'missing stale root element' unless self.yaml['stale']

    # Grab Configuration from YAML
    self.configuration = self.yaml['stale'].delete('configuration')
    use_fakeweb = (configuration['use_fakeweb'] || false) unless configuration.nil?

    # Process remaining nodes as items
    self.yaml['stale'].each do |key, value|
      %w{ filepath frequency source }.each { |field| raise YAML::Error, "missing #{field} node for #{key}" unless value[field] }
    end
  end

protected

  def self.flag_stale(args)
    force = args.pop[:force] if args.last.is_a?(Hash)
    stale, scope = {}, self.yaml['stale']
    scope.each do |key, value|
      if args.empty?
        if value['updated'].blank?
          stale.merge!({key => value})
        else
          last_modified = value['updated']
          update_on = DateTime.now + eval(value['frequency'])
          if last_modified > update_on
            stale.merge!({key => value})
          else
            register_uri(value['source'], value['filepath'])
          end
        end
      else
        last_modified = value['updated']
        update_on = DateTime.now + eval(value['frequency'])
        if force == true
          stale.merge!({key => value}) if args.include?(key)
        else
          if args.include?(key) && (value['updated'].blank? || last_modified > update_on)
            stale.merge!({key => value})
          else
            register_uri(value['source'], value['filepath'])
          end
        end
      end
    end
    return stale
  end

  def self.process(fixtures)
    FakeWeb.allow_net_connect = true if use_fakeweb

    fixtures.each do |key, value|

      begin
        @response = http.resource(value['source']).get
        File.open(value['filepath'], 'w') { |f| f.write @response.body.to_s }
        update_fixture(key)
      rescue Resourceful::UnsuccessfulHttpRequestError
        raise FixtureUpdateFailure, "#{key}'s source: #{value['source']} returned unsuccessfully."
      rescue ArgumentError
        raise MalformedSourceURL, "#{key}'s source: #{value['source']} is not a valid URL path. Most likely it's missing a trailing slash."
      end

      register_uri(value['source'], value['filepath'])
    end

    FakeWeb.allow_net_connect = false if use_fakeweb
  end

  def self.update_fixture(key)
    self.yaml['stale'][key]['updated'] = DateTime.now
  end

  def self.write_yaml
  end

end
