require 'singleton'

module StaleFish
  module Utility
    class << self
      attr_accessor :config_path
    end

    def self.valid_path?
      !config_path.nil? ? File.exist?(config_path) : false
    end

    def self.loader
      # TODO: migrate YAML loader (ref. StaleFish.load_yaml)
    end

    def self.validate_syntax
      # TODO: migrate YAML syntax validation (ref. StaleFish.load_yaml)
    end

    def self.writer
      File.open(config_path, "w+") do |f|
        f.write(self.yaml.to_yaml)
      end
    end
  end
end
