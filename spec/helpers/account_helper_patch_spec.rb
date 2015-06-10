require "spec_helper"

describe AccountHelper do
  include Redmine::OmniAuthCAS::AccountHelperPatch
  include Redmine::I18n

  context "#label_for_cas_login" do
    it "should use label_login_with_cas plugin setting if not blank" do
      label = "Log in with SSO"
      Setting["plugin_redmine_omniauth_cas"]["label_login_with_cas"] = label
      expect(label_for_cas_login).to eq label
    end

    it "should default to localized :label_login_with_cas if no setting present" do
      Setting["plugin_redmine_omniauth_cas"]["label_login_with_cas"] = nil
      expect(label_for_cas_login).to eq l(:label_login_with_cas)
    end
  end
end
