require 'omniauth/cas'

module Omniauth::Patches
  # patch to disable return_url to avoid polluting the service URL
  def return_url
    {}
  end
end

module OmniAuth
  module Strategies
    class CAS
      prepend Omniauth::Patches

      # patch to accept path (subdir) in cas_host
      option :path, nil

      # patch to accept a different host for service_validate_url
      def service_validate_url_with_different_host(service_url, ticket)
        service_url = Addressable::URI.parse(service_url)
        service_url.query_values = service_url.query_values.tap { |qs| qs.delete('ticket') }

        validate_url = Addressable::URI.parse(@options.service_validate_url)

        if service_url.host.nil? || validate_url.host.nil?
          cas_url + append_params(@options.service_validate_url, { :service => service_url.to_s, :ticket => ticket })
        else
          append_params(@options.service_validate_url, { :service => service_url.to_s, :ticket => ticket })
        end
      end

      # alias_method_chain is deprecated in Rails 5: replaced with two alias_method
      # as a quick workaround. Using the 'prepend' method can generate an
      # 'stack level too deep' error in conjunction with other (non ported) plugins.
      # alias_method_chain :service_validate_url, :different_host
      alias_method :service_validate_url_without_different_host, :service_validate_url
      alias_method :service_validate_url, :service_validate_url_with_different_host

    end
  end
end
