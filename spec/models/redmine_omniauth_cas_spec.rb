require "spec_helper"

describe "RedmineOmniAuthCAS" do
  context "#cas_service_validate_url" do
    it "should return setting if not blank" do
      url = "cas.example.com/validate"
      Setting["plugin_redmine_omniauth_cas"]["cas_service_validate_url"] = url
      expect(Redmine::OmniAuthCAS.cas_service_validate_url).to eq url
    end

    it "should return nil if setting is blank" do
      Setting["plugin_redmine_omniauth_cas"]["cas_service_validate_url"] = ""
      expect(Redmine::OmniAuthCAS.cas_service_validate_url).to be_nil
    end
  end
end
