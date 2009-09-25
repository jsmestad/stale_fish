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
      raise Errno::ENOENT, 'invalid config path: #{Utility.config_path}; ensure StaleFish::Utility.valid_path? is true' unless Utility.valid_path?

      data = YAML.load_file(config_path)

      config = data['stale'].delete('configuration')
      StaleFish.use_fakeweb = (config['use_fakeweb'] || false) unless config.nil?

      raise YAML::Error, 'missing root element' unless data['stale']

      # Reset these
      StaleFish.fixtures = []
      StaleFish.force_flag = false

      deprecated_var_names = {
        'file_path' => 'filepath',
        'update_frequency' => 'frequency',
        'source_url' => 'source',
        'last_updated_at' => 'updated'
      }

      data['stale'].each do |key, value|
        definition = FixtureDefinition.new
        definition.tag = key
        %w{ file_path update_frequency source_url }.each do |field|
          if value[deprecated_var_names[field]]
            $stderr.puts "Deprecation warning: #{field} has been replaced with #{deprecated_var_names[field]}. Please update #{Utility.config_path}."
            definition.send((field + '=').to_sym, value[deprecated_var_names[field]])
          else
            raise YAML::Error, "missing #{field} node for #{key} in #{Utility.config_path}" unless value[field]
            definition.send((field + '=').to_sym, value[field])
          end
        end

        $stderr.puts "Deprecation warning: updated has been changed to last_updated_at; this change is automatic." if value.has_key?('updated')
        definition.last_updated_at = value['last_updated_at'] || value[deprecated_var_names['last_updated_at']] || nil

        StaleFish.fixtures << definition
      end
    end

    def self.writer
      string = <<-EOF
stale:
  configuration:
    use_fakeweb: #{StaleFish.use_fakeweb}
EOF
      StaleFish.fixtures.each do |fix|
        string << fix.output_hash
      end

      File.open(config_path, "w+") { |f| f.write(string) }
    end
  end
end