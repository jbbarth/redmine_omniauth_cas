module RedmineOmniauthCas
  class << self
    def settings_hash
      Setting["plugin_redmine_omniauth_cas"]
    end

    def enabled?
      settings_hash["enabled"]
    end

    def yaml_config_path
      @yaml_config_path ||= File.join(Rails.root, 'config', 'omniauth_cas.yml')
    end

    def yaml_config_exists?
      File.exist?(yaml_config_path) && File.readable?(yaml_config_path)
    end

    def yaml_config
      return @yaml_config if defined?(@yaml_config)

      if yaml_config_exists?
        begin
          content = File.read(yaml_config_path)
          @yaml_config = YAML.safe_load(content) || {}
          Rails.logger.info "Loaded CAS configuration from YAML: #{yaml_config_path}"
        rescue => e
          Rails.logger.error "Error loading CAS YAML config: #{e.message}"
          @yaml_config = {}
        end
      else
        @yaml_config = {}
      end

      @yaml_config
    end

    def from_yaml_config_file?(setting_name)
      case setting_name
      when 'cas_server', 'cas_service_validate_url'
        yaml_config[setting_name].present?
      else
        false
      end
    end

    # Priority: YAML > Database settings
    def cas_server
      yaml_config['cas_server'].presence || settings_hash["cas_server"]
    end

    # Priority: YAML > Database settings
    def cas_service_validate_url
      yaml_value = yaml_config['cas_service_validate_url'].presence
      return yaml_value if yaml_value

      settings_hash["cas_service_validate_url"].presence || nil
    end

    def label_login_with_cas
      settings_hash["label_login_with_cas"]
    end
  end
end
