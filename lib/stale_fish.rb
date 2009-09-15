require 'singleton'
require 'ftools'
require 'yaml'
require 'rubygems'
require 'activesupport' # only used for time helpers
require 'rio'
begin
  require "fakeweb"
rescue LoadError

end

module StaleFish
  # no one likes stale fish.

  class << self
    attr_accessor :use_fakeweb
    attr_accessor :config_path
    attr_accessor :yaml
  end

  self.use_fakeweb = false

  def self.valid_path?
    return false if @config_path.nil?
    File.exist?(@config_path)
  end

  def self.update_stale(*args)
    # check each file for update
    load_yaml if self.yaml.nil?
    stale = flag_stale(args)
    process(stale)
    write_yaml
    return stale.size
  end

  def self.register_uri(source_uri, response)
    if self.use_fakeweb && !FakeWeb.registered_uri?(source_uri)
      FakeWeb.register_uri(:any, source_uri, :body => response)
    end
  end

  def self.load_yaml
    if valid_path?
      self.yaml = YAML.load_file(@config_path)
      check_syntax
    else
      raise Errno::ENOENT, 'invalid path, please set StaleFish.config_path than ensure StaleFish.valid_path? is true'
    end
  end

protected

  def self.check_syntax
    raise YAML::Error, 'missing stale root element' unless @yaml['stale']

    # Grab Configuration from YAML
    @configuration = self.yaml['stale'].delete('configuration')
    self.use_fakeweb = (@configuration['use_fakeweb'] || false) unless @configuration.nil?

    # Process remaining nodes as items
    self.yaml['stale'].each do |key, value|
      %w{ filepath frequency source }.each do |field|
        raise YAML::Error, "missing #{field} node for #{key}" unless self.yaml['stale'][key][field]
      end
    end
  end

  def self.flag_stale(args)
    force = args.pop[:force] if args.last.is_a?(Hash)
    stale, scope = {}, self.yaml['stale']
    scope.each do |key, value|
      if args.empty?
        if scope[key]['updated'].blank?
          stale.merge!({key => scope[key]})
        else
          last_modified = scope[key]['updated']
          update_on = DateTime.now + eval(scope[key]['frequency'])
          if last_modified > update_on
            stale.merge!({key => scope[key]})
          else
            self.register_uri(scope[key]['source'], scope[key]['filepath'])
          end
        end
      else
        last_modified = scope[key]['updated']
        update_on = DateTime.now + eval(scope[key]['frequency'])
        if force == true
          stale.merge!({key => scope[key]}) if args.include?(key)
        else
          if args.include?(key) && (scope[key]['updated'].blank? || last_modified > update_on)
            stale.merge!({key => scope[key]})
          else
            self.register_uri(scope[key]['source'], scope[key]['filepath'])
          end
        end
      end
    end
    return stale
  end

  def self.process(fixtures)
    FakeWeb.allow_net_connect = true if self.use_fakeweb

    fixtures.each do |key, value|
      rio(fixtures[key]['source']) > rio(fixtures[key]['filepath'])
      self.register_uri(fixtures[key]['source'], fixtures[key]['filepath'])
      update_fixture(key)
    end

    FakeWeb.allow_net_connect = false if self.use_fakeweb
  end

  def self.update_fixture(key)
    self.yaml['stale'][key]['updated'] = DateTime.now
  end

  def self.write_yaml
    File.open(@config_path, "w+") do |f|
      f.write(@yaml.to_yaml)
    end
  end

end
