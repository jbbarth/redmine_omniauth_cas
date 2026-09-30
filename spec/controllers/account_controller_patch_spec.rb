# frozen_string_literal: true

require "spec_helper"

describe AccountController, type: :controller do
  render_views
  fixtures :users, :roles

  context "GET /login CAS button" do
    it "should show up only if there's a plugin setting for CAS URL" do
      Setting["plugin_redmine_omniauth_cas"]["cas_server"] = ""
      get :login
      assert_select '#cas-login', 0
      Setting["plugin_redmine_omniauth_cas"]["cas_server"] = "blah"
      get :login
      assert_select '#cas-login'
    end

    it "should correct double-escaped URL" do
      #I don't really know where this bug comes from but it seems URLs are escaped twice
      #in my setup which causes the back_url to be invalid. Let's try to be smart about
      #this directly in the plugin 
      Setting["plugin_redmine_omniauth_cas"]["cas_server"] = "blah"
      get :login, params: {:back_url => "https%3A%2F%2Fblah%2F"}
      assert_select '#cas-login > form[action=?]', '/auth/cas?origin=https%3A%2F%2Fblah%2F'
    end
  end

  context "GET /login when CAS replaces the Redmine login" do
    before do
      @previous_settings = Setting["plugin_redmine_omniauth_cas"]
      Setting["plugin_redmine_omniauth_cas"] = @previous_settings.merge("enabled" => "true", "replace_redmine_login" => "true")
    end

    after do
      Setting["plugin_redmine_omniauth_cas"] = @previous_settings
    end

    it "posts to the CAS provider with the back url as origin" do
      allow(controller).to receive(:protect_against_forgery?).and_return(true)
      get :login, params: {:back_url => "/projects"}
      assert_select 'form[method=post][action=?]', '/auth/cas' do
        assert_select 'input[name=authenticity_token]'
        assert_select 'input[name=origin][value=?]', '/projects'
      end
    end

    it "escapes the back url" do
      get :login, params: {:back_url => '"><script>alert(1)</script>'}
      expect(response.body).not_to include('"><script>alert(1)</script>')
      assert_select 'input[name=origin][value=?]', '"><script>alert(1)</script>'
    end
  end

  context "GET login_with_cas_callback" do
    it "should redirect to /my/page after successful login" do
      request.env["omniauth.auth"] = {"uid" => "admin"}
      get :login_with_cas_callback, params: {:provider => "cas"}
      expect(response).to redirect_to('/my/page')
    end

    it "should redirect to /login after failed login" do
      request.env["omniauth.auth"] = {"uid" => "non-existent"}
      Setting["plugin_redmine_omniauth_cas"]["cas_server"] = "http://cas.server/"
      get :login_with_cas_callback, params: {:provider => "cas"}
      expect(response).to redirect_to('/login')
    end

    it "should set a boolean in session to keep track of login" do
      request.env["omniauth.auth"] = {"uid" => "admin"}
      get :login_with_cas_callback, params: {:provider => "cas"}
      expect(response).to redirect_to('/my/page')
      assert session[:logged_in_with_cas]
    end

    it "should redirect to Home if not logged in with CAS" do
      get :logout
      expect(response).to redirect_to(home_url)
    end

    it "should redirect to CAS logout if previously logged in with CAS" do
      session[:logged_in_with_cas] = true
      Setting["plugin_redmine_omniauth_cas"]["cas_server"] = "http://cas.server"
      get :logout
      expect(response).to redirect_to('http://cas.server/logout?gateway=1&service=http://test.host/')
    end

    it "should respect path in CAS server when generating logout url" do
      session[:logged_in_with_cas] = true
      Setting["plugin_redmine_omniauth_cas"]["cas_server"] = "http://cas.server/cas"
      get :logout
      expect(response).to redirect_to('http://cas.server/cas/logout?gateway=1&service=http://test.host/')
    end
  end
end
