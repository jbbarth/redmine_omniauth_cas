
# OmniAuth CAS
setup_app = Proc.new do |env|
  addr = RedmineOmniauthCas.cas_server
  cas_server = URI.parse(addr)
  if cas_server
    env['omniauth.strategy'].options.merge! :host => cas_server.host,
                                            :port => cas_server.port,
                                            :path => (cas_server.path != "/" ? cas_server.path : nil),
                                            :ssl => cas_server.scheme == "https"
  end
  validate = RedmineOmniauthCas.cas_service_validate_url
  if validate.present?
    env['omniauth.strategy'].options.merge! :service_validate_url => validate
  end
  # Dirty, not happy with it, but as long as I can't reproduce the bug
  # users are blocked because of failing OpenSSL checks, while the cert
  # is actually good, so...
  # TODO: try to understand why cert verification fails
  # Maybe https://github.com/intridea/omniauth/issues/404 can help
  env['omniauth.strategy'].options.merge! :disable_ssl_verification => true
end

begin
  # tell Rails we use this middleware, with some default value just in case
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :cas, :host => "localhost",
             :port => "9292",
             :ssl => false,
             :setup => setup_app
  end
rescue FrozenError
  # This can happen if there is a crash after Rails has
  # started booting but before we've added our middleware.
  # The middlewares array will only be frozen if an earlier error occurs
  Rails.logger.warn("Unable to add OmniAuth::Builder middleware as the middleware stack is frozen")
  puts "/!\\ Unable to add OmniAuth::Builder middleware as the middleware stack is frozen"
end
