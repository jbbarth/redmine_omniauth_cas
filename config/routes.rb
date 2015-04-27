RedmineApp::Application.routes.draw do
  match 'auth/failure', :controller => 'account', :action => 'login_with_cas_failure', via: [:get, :post]
  match 'auth/:provider/callback', :controller => 'account', :action => 'login_with_cas_callback', via: [:get, :post]
  match 'auth/:provider', :controller => 'account', :action => 'login_with_cas_redirect', via: [:get, :post]
end
