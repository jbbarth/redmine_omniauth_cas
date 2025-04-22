require "spec_helper"

describe "AccountPatch", :type => :request do
  fixtures :users, :roles, :email_addresses

  context "GET /auth/:provider" do
    it "should route to a blank action (intercepted by omniauth middleware)" do
      assert_routing(
        { :method => :get, :path => "/auth/blah" },
        { :controller => 'account', :action => 'login_with_cas_redirect', :provider => 'blah' }
      )
    end
    # TODO: some real test?
  end
  context "GET /auth/:provider/callback" do
    it "should route things correctly" do
      assert_routing(
        { :method => :get, :path => "/auth/blah/callback" },
        { :controller => 'account', :action => 'login_with_cas_callback', :provider => 'blah' }
      )
    end

    context "OmniAuth CAS strategy" do
      before do
        Setting.default_language = 'en'
        OmniAuth.config.test_mode = true
      end

      it "should authorize login if user exists with this login" do
        OmniAuth.config.mock_auth[:cas] = OmniAuth::AuthHash.new({ 'uid' => 'admin' })
        Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:cas]
        get '/auth/cas/callback'
        expect(response).to redirect_to('/my/page')
        get '/my/page'
        expect(response.body).to match /Logged in as.*admin/im
      end

      it "should authorize login if user exists with this email" do
        OmniAuth.config.mock_auth[:cas] = OmniAuth::AuthHash.new({ 'uid' => 'admin@somenet.foo' })
        Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:cas]
        get '/auth/cas/callback'
        expect(response).to redirect_to('/my/page')
        get '/my/page'
        expect(response.body).to match /Logged in as.*admin/im
      end

      it "should update last_login_on field" do
        user = User.find(1)
        user.update_attribute(:last_login_on, Time.now - 6.hours)
        OmniAuth.config.mock_auth[:cas] = OmniAuth::AuthHash.new({ 'uid' => 'admin' })
        Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:cas]
        get '/auth/cas/callback'
        expect(response).to redirect_to('/my/page')
        user.reload
        assert Time.now - user.last_login_on < 30.seconds
      end

      it "should refuse login if user doesn't exist" do
        OmniAuth.config.mock_auth[:cas] = OmniAuth::AuthHash.new({ 'uid' => 'johndoe' })
        Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:cas]
        get '/auth/cas/callback'
        expect(response).to redirect_to('/login')
        follow_redirect!
        expect(User.current).to eq User.anonymous
        assert_select 'div.flash.error', :text => /Invalid user or password/
      end

      it "should log in the test user" do
        OmniAuth.config.mock_auth[:cas] = OmniAuth::AuthHash.new({ 'uid' => 'test_user' })
        Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:cas]
        get '/auth/cas/callback'
        expect(response).to redirect_to('/my/page')
        follow_redirect!
        expect(response.body).to include('Logged in as test_user')
      end
    end
  end
end
