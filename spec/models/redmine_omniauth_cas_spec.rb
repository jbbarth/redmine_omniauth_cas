require "spec_helper"

describe "RedmineOmniAuthCAS" do
  context "#cas_service_validate_url" do
    it "should return setting if not blank" do
      url = "cas.example.com/validate"
      Setting["plugin_redmine_omniauth_cas"]["cas_service_validate_url"] = url
      Redmine::OmniAuthCAS.cas_service_validate_url.should == url
    end

    it "should return nil if setting is blank" do
      Setting["plugin_redmine_omniauth_cas"]["cas_service_validate_url"] = ""
      Redmine::OmniAuthCAS.cas_service_validate_url.should == nil
    end
  end
end
