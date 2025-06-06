# configures public url for our application
module OmniAuth::DynamicFullHost
  def self.full_host_url(url = nil)
    # unescapes url on-the-fly because it might be double-escaped in some environments
    #(it happens for me at work with 2 reverse-proxies in front of the app...)
    url = CGI.unescape(url) if url

    # if no url found, fall back to config/app_config.yml addresses
    if url.blank?
      url = Setting["host_name"]
      # else, parse it and remove both request_uri and query_string
    else
      uri = URI.parse(URI::Parser.new.escape(url)) # Encode to ensure we only have ASCII charaters in url
      url = "#{uri.scheme}://#{uri.host}"
      url << ":#{uri.port}" unless uri.default_port == uri.port
    end
    url
  end
end

OmniAuth.config.full_host = Proc.new do |env|
  OmniAuth::DynamicFullHost.full_host_url(env["rack.session"]["omniauth.origin"] || env["omniauth.origin"])
end
