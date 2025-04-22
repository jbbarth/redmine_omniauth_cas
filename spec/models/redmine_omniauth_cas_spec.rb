require "spec_helper"

describe "RedmineOmniAuthCAS" do
  context "#cas_service_validate_url" do
    it "should return setting if not blank" do
      url = "cas.example.com/validate"
      Setting["plugin_redmine_omniauth_cas"]["cas_service_validate_url"] = url
      expect(RedmineOmniauthCas.cas_service_validate_url).to eq url
    end

    it "should return nil if setting is blank" do
      Setting["plugin_redmine_omniauth_cas"]["cas_service_validate_url"] = ""
      expect(RedmineOmniauthCas.cas_service_validate_url).to be_nil
    end
  end

  context "dynamic full host" do
    it "should return host name from setting if no url" do
      Setting["host_name"] = "http://redmine.example.com"
      expect(OmniAuth::DynamicFullHost.full_host_url).to eq "http://redmine.example.com"
    end

    it "should return host name from url if url is present" do
      url = "https://redmine.example.com:3000/some/path"
      expect(OmniAuth::DynamicFullHost.full_host_url(url)).to eq "https://redmine.example.com:3000"
    end
  end
end
