require_dependency 'application_controller'

module PluginOmniauthCas
  module ApplicationController

    def back_url
      url = params[:back_url]
      if url.nil? && referer = request.env['HTTP_REFERER']
        url = CGI.unescape(referer.to_s)
      else
        url = CGI.unescape(url) unless url.nil?
      end
      # URLs that contains the utf8=[checkmark] parameter added by Rails are
      # parsed as invalid by URI.parse so the redirect to the back URL would
      # not be accepted (ApplicationController#validate_back_url would return
      # false)
      url.gsub!(/(\?|&)utf8=\u2713&?/, '\1') unless url.nil?
      url
    end

    def require_login
      if !User.current.logged?
        # Extract only the basic url parameters on non-GET requests
        if request.get?
          url = request.original_url

          ## START PATCH
          url.gsub!('http:', Setting.protocol + ":")
          ## END PATCH

        else
          url = url_for(:controller => params[:controller], :action => params[:action], :id => params[:id], :project_id => params[:project_id])
        end
        respond_to do |format|
          format.html {
            if request.xhr?
              head :unauthorized
            else
              redirect_to signin_path(:back_url => url)
            end
          }
          format.any(:atom, :pdf, :csv) {
            redirect_to signin_path(:back_url => url)
          }
          format.api {
            if (Setting.rest_api_enabled? && accept_api_auth?) || Redmine::VERSION.to_s < '4.1'
              head(:unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"')
            else
              head(:forbidden)
            end
          }
          format.js {head :unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"'}
          format.any {head :unauthorized}
        end
        return false
      end
      true
    end

    # Returns a validated URL string if back_url is a valid url for redirection,
    # otherwise false
    def validate_back_url(back_url)
      return false if back_url.blank?

      if CGI.unescape(back_url).include?('..')
        return false
      end

      begin
        uri = URI.parse(back_url)
      rescue URI::InvalidURIError
        return false
      end

      ## PATCHED : ignore scheme HTTPS/HTTP and port so redirection works behind reverse proxies
      [:host].each do |component|
        if uri.send(component).present? && uri.send(component) != request.send(component)
          return false
        end
      end
      uri.scheme = nil
      uri.host = nil
      uri.port = nil

      # Always ignore basic user:password in the URL
      uri.userinfo = nil

      path = uri.to_s
      # Ensure that the remaining URL starts with a slash, followed by a
      # non-slash character or the end
      if path !~ %r{\A/([^/]|\z)}
        return false
      end

      if path.match(%r{/(login|account/register|account/lost_password)})
        return false
      end

      if relative_url_root.present? && !path.starts_with?(relative_url_root)
        return false
      end

      return path
    end

  end
end

ApplicationController.prepend PluginOmniauthCas::ApplicationController
