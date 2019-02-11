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
      url
    end

    def require_login
      if !User.current.logged?
        # Extract only the basic url parameters on non-GET requests
        if request.get?
          url = request.original_url

          ## START PATCH
          url.gsub!('http:', Setting.protocol+":")
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
          format.xml  { head :unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"' }
          format.js   { head :unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"' }
          format.json { head :unauthorized, 'WWW-Authenticate' => 'Basic realm="Redmine API"' }
          format.any  { head :unauthorized }
        end
        return false
      end
      true
    end

  end
end

ApplicationController.prepend PluginOmniauthCas::ApplicationController
