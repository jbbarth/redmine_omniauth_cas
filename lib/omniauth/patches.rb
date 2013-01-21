require 'omniauth/cas'

module OmniAuth
  module Strategies
    class CAS
      # patch to accept path (subdir) in cas_host
      option :path, nil

      def cas_host_with_path
        @cas_host ||= cas_host_without_path + @options.path.to_s
      end
      alias_method_chain :cas_host, :path

      # patch to accept a different host for service_validate_url
      def service_validate_url_with_different_host(service_url, ticket)
        service_url = Addressable::URI.parse( service_url )
        service_url.query_values = service_url.query_values.tap { |qs| qs.delete('ticket') }

        validate_url = Addressable::URI.parse( @options.service_validate_url )

        if service_url.host.nil? || validate_url.host.nil?
          cas_host + append_params(@options.service_validate_url, { :service => service_url.to_s, :ticket => ticket })
        else
          append_params(@options.service_validate_url, { :service => service_url.to_s, :ticket => ticket })
        end
      end
      alias_method_chain :service_validate_url, :different_host

      # patch to use omniauth.origin for the full_host (if available), to deal with reverse proxy issues
      def full_host_with_origin
        url = env["rack.session"]["omniauth.origin"] || env["omniauth.origin"]
        if url.blank?
          url = full_host_without_origin
        else
          uri = URI.parse(url)
          url = "#{uri.scheme}://#{uri.host}"
          url << ":#{uri.port}" unless uri.default_port == uri.port
        end
        url
      end
      alias_method_chain :full_host, :origin

      # patch to disable return_url to avoid polluting the service URL
      def return_url
        {}
      end
    end
  end
end
