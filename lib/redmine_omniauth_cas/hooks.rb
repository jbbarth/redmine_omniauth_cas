module RedmineOmniauthCas
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_account_login_top, :partial => 'redmine_omniauth_cas/view_account_login_top'
  end

  class ModelHook < Redmine::Hook::Listener
    def after_plugins_loaded(_context = {})
      require_relative 'account_controller_patch'
      require_relative 'account_helper_patch'
      require_relative 'application_controller_patch'
      require_relative 'user_patch'
    end
  end
end
