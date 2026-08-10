require "spec_helper"

# In production the reverse proxy forwards requests in plain http, as the test
# environment does
describe "Behind a reverse proxy", :type => :request do
  fixtures :users, :email_addresses

  it "sends an https back_url to the login page when the site is served over https" do
    with_settings :protocol => 'https' do
      get '/my/page'

      expect(response).to be_redirect
      expect(response.location).to include('back_url=https%3A%2F%2Fwww.example.com%2Fmy%2Fpage')
    end
  end

  it "leaves the back_url in http when the site is served over http" do
    with_settings :protocol => 'http' do
      get '/my/page'

      expect(response).to be_redirect
      expect(response.location).to include('back_url=http%3A%2F%2Fwww.example.com%2Fmy%2Fpage')
    end
  end

  it "only rewrites the protocol of the url itself, not urls carried in its query string" do
    with_settings :protocol => 'https' do
      get '/my/page', :params => {:foo => 'http://example.net/'}

      back_url = CGI.unescape(CGI.unescape(response.location))
      expect(back_url).to include('back_url=https://www.example.com/my/page?foo=http://example.net/')
    end
  end
end
