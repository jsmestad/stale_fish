require 'singleton'
require 'ftools'
require 'yaml'
require 'rubygems'
require 'activesupport' # only used for time helpers
require 'rio'

module StaleFish
  # no one likes stale fish.

  def self.config_path=(path)
    @config_path = path
  end

  def self.config_path
    @config_path
  end

  def self.valid_path?
    return false if @config_path.nil?
    File.exist?(@config_path)
  end

  def self.update_stale(*args)
    # check each file for update
    load_yaml unless @yaml
    stale = flag_stale(args)
    process(stale)
    write_yaml
    return stale.size
  end

  def self.load_yaml
    if valid_path?
      @yaml = YAML.load_file(@config_path)
      check_syntax
    else
      raise Errno::ENOENT, 'invalid path, please set StaleFish.config_path than ensure StaleFish.valid_path? is true'
    end
  end

protected

  def self.check_syntax
    raise YAML::Error, 'missing stale root element' unless @yaml['stale']
    @yaml['stale'].each do |key, value|
      %w{ filepath frequency source }.each do |field|
        raise YAML::Error, "missing #{field} node for #{key}" unless @yaml['stale'][key][field]
      end
    end
  end

  def self.flag_stale(args)
    force = args.pop[:force] if args.last.is_a?(Hash)
    stale, scope = {}, @yaml['stale']
    scope.each do |key, value|
      if args.empty?
        if scope[key]['updated'].blank?
          stale.merge!({key => scope[key]}) 
        else
          last_modified = scope[key]['updated']
          update_on = DateTime.now + eval(scope[key]['frequency'])
          stale.merge!({key => scope[key]}) if last_modified > update_on
        end
      else
        last_modified = scope[key]['updated']
        update_on = DateTime.now + eval(scope[key]['frequency'])
        if force == true
          stale.merge!({key => scope[key]}) if args.include?(key)
        else
          stale.merge!({key => scope[key]}) if args.include?(key) && (scope[key]['updated'].blank? || last_modified > update_on)
        end
      end
    end
    return stale
  end

  def self.process(fixtures)
    fixtures.each do |key, value|
      rio(fixtures[key]['source']) > rio(fixtures[key]['filepath'])
      update_fixture(key)
    end
  end

  def self.update_fixture(key)
    @yaml['stale'][key]['updated'] = DateTime.now
  end

  def self.write_yaml
    File.open(@config_path, "w+") do |f|
      f.write(@yaml.to_yaml)
    end
  end

end
