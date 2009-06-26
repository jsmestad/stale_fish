require 'singleton'
require 'ftools'
require 'yaml'
require 'rubygems'
require 'activesupport' # only used for time helpers
require 'rio'

module StalePopcorn
  # no one likes stale popcorn.

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

  def self.update_stale(options={})
    # check each file for update
    load_yaml unless @yaml
    stale = flag_stale
    process(stale)
    write_yaml
  end

  def self.load_yaml
    if valid_path?
      @yaml = YAML.load_file(@config_path)
      check_syntax
    else
      raise Errno::ENOENT, 'invalid path, please set StalePopcorn.config_path than ensure StalePopcorn.valid_path? is true'
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

  def self.flag_stale
    stale = {}
    scope = @yaml['stale']
    scope.each do |key, value|
      if scope[key]['updated'].blank?
        stale.merge!({key => scope[key]})
      else
        last_modified = scope[key]['updated']
        update_on = DateTime.now + eval(scope[key]['frequency'])
        stale.merge!({key => scope[key]}) if last_modified > update_on
      end
    end
    return stale
  end

  def self.process(fixtures)
    p fixtures
    fixtures.each do |key, value|
      rio(fixtures[key]['source']) > rio(fixtures[key]['filepath'])
      @yaml['stale'][key]['updated'] = DateTime.now
    end
    true
  end

  def self.write_yaml
    File.open(@config_path, "w+") do |f|
      f.write(@yaml.to_yaml)
    end
  end
  

end
