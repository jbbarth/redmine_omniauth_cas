require_dependency 'account_controller'

module Redmine::OmniAuthCAS
  module AccountControllerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable
        alias_method_chain :login, :cas
        alias_method_chain :logout, :cas
        alias_method_chain :register, :cas
      end
    end

    module InstanceMethods

      def login_with_cas
        if cas_settings[:enabled] && cas_settings[:replace_redmine_login]
          redirect_to :controller => "account", :action => "login_with_cas_redirect", :provider => "cas", :origin => back_url
        else
          login_without_cas
        end
      end

      def login_with_cas_redirect
        render :text => "Not Found", :status => 404
      end

      def login_with_cas_callback
        auth = request.env["omniauth.auth"]
        user = find_or_create_user_from_cas(auth)
        if user.nil?
          # Unknown user and on-the-fly creation is disabled
          logger.warn "Failed login for '#{auth[:uid]}' from #{request.remote_ip} at #{Time.now.utc}"
          error = l(:notice_account_invalid_creditentials).sub(/\.$/, '')
          if cas_settings[:cas_server].present?
            link = self.class.helpers.link_to(l(:text_logout_from_cas), cas_logout_url, :target => "_blank")
            error << ". #{l(:text_full_logout_proposal, :value => link)}"
          end
          if cas_settings[:replace_redmine_login]
            render_error({:message => error.html_safe, :status => 403})
            return false
          else
            flash[:error] = error
            redirect_to signin_url
          end
        elsif user.new_record?
          # On-the-fly creation is enabled but could not extract all values from attributes
          session[:auth_source_registration] = {:login => user.login, :auth_source_id => user.auth_source_id, :user => user, :from_cas => true}
          redirect_to register_url
        else
          # Valid user
          params[:back_url] = request.env["omniauth.origin"] unless request.env["omniauth.origin"].blank?
          successful_authentication(user)
          session[:logged_in_with_cas] = true
        end
      end

      def login_with_cas_failure
        error = params[:message] || 'unknown'
        error = 'error_cas_' + error
        if cas_settings[:replace_redmine_login]
          render_error({:message => error.to_sym, :status => 500})
          return false
        else
          flash[:error] = l(error.to_sym)
          redirect_to signin_url
        end
      end

      def logout_with_cas
        if cas_settings[:enabled] && session[:logged_in_with_cas]
          logout_user
          redirect_to cas_logout_url(home_url)
        else
          logout_without_cas
        end
      end

      def register_with_cas
        from_cas = session[:auth_source_registration][:from_cas] if session[:auth_source_registration]
        if request.get? && from_cas && session[:auth_source_registration][:user]
          # First redirection to registration page after successful CAS authentication
          @user = session[:auth_source_registration][:user]
        else
          # Normal form handling process
          register_without_cas
        end
        if from_cas
          if !performed?
            # Setup specific registration view (without login/password fields)
            render :register_with_cas
          elsif User.current.logged?
            # Successful self-registration, mark the user as logged in from CAS for proper logout
            session[:logged_in_with_cas] = true
          end
        end
      end

      private
      def cas_settings
        Redmine::OmniAuthCAS.settings_hash
      end

      def cas_logout_url(service = nil)
        logout_uri = URI.parse(cas_settings[:cas_server] + "/").merge("./logout")
        if !service.blank?
          logout_uri.query = "service=#{service}"
        end
        logout_uri.to_s
      end

      def find_or_create_user_from_cas(auth)
        user = User.find_by_login(auth["uid"]) || User.find_by_mail(auth["uid"])
        if user
          # User is already in local database
          return nil if !user.active?
        elsif cas_settings[:onthefly_registration]
          # Create user on-the-fly
          user = User.new(get_user_attrs_from_cas(auth))
          user.login = auth["uid"]
          user.auth_source_id = cas_settings[:onthefly_authsource_id].to_i if !cas_settings[:onthefly_authsource_id].blank?
          user.random_password
          if user.save
            user.reload
            Rails.logger.info("User '#{user.login}' created from CAS")
          end
        end
        user.update_attribute(:last_login_on, Time.now) if user && !user.new_record?
        user
      end

      def get_user_attrs_from_cas(auth)
        cas_attrs = auth["extra"]["attributes"][0] if auth["extra"] && auth["extra"]["attributes"]
        cas_attrs ||= auth["extra"]
        all_attrs = auth["info"].merge(cas_attrs)
        user_attrs = {
          :firstname => all_attrs[cas_settings[:attr_firstname]],
          :lastname => all_attrs[cas_settings[:attr_lastname]],
          :mail => all_attrs[cas_settings[:attr_mail]],
          :language => Setting.default_language
        }
        user_attrs
      end

    end
  end
end

unless AccountController.included_modules.include? Redmine::OmniAuthCAS::AccountControllerPatch
  AccountController.send(:include, Redmine::OmniAuthCAS::AccountControllerPatch)
end
