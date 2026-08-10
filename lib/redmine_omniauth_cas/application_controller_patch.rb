require_dependency 'application_controller'

module RedmineOmniauthCas
  module ApplicationControllerPatch
    extend ActiveSupport::Concern

    # Returns a validated URL string if back_url is a valid url for redirection,
    # otherwise false
    def validate_back_url(back_url)
      return false if back_url.blank?

      if CGI.unescape(back_url).include?('..')
        return false
      end

      begin
        uri = Addressable::URI.parse(back_url)
        ## PATCHED : ignore scheme HTTPS/HTTP and port so redirection works behind reverse proxies
        [:host].each do |component|
          if uri.send(component).present? && uri.send(component) != request.send(component)
            return false
          end
        end
        # Remove unnecessary components to convert the URL into a relative URL
        uri.omit!(:scheme, :authority)
      rescue Addressable::URI::InvalidURIError
        return false
      end

      path = uri.to_s
      # Ensure that the remaining URL starts with a slash, followed by a
      # non-slash character or the end
      unless %r{\A/([^/]|\z)}.match?(path)
        return false
      end

      if %r{/(login|account/register|account/lost_password)}.match?(path)
        return false
      end

      if relative_url_root.present? && !path.starts_with?(relative_url_root)
        return false
      end

      return path
    end

  end
end

ApplicationController.prepend RedmineOmniauthCas::ApplicationControllerPatch
