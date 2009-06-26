require 'singleton'
require 'ftools'
require 'yaml'
require 'rubygems'
require 'activesupport' # only used for time helpers

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
      %w{ filepath frequency source updated }.each do |field|
        raise YAML::Error, "missing #{field} node for #{key}" unless key[field]
      end
    end
  end

end
