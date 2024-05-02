# frozen_string_literal: true

require 'redmine'
require_relative 'lib/redmine_omniauth_cas'
require_relative 'lib/redmine_omniauth_cas/hooks'
require_relative 'lib/omniauth/patches'
require_relative 'lib/omniauth/dynamic_full_host'

# Plugin generic informations
Redmine::Plugin.register :redmine_omniauth_cas do
  name 'Redmine Omniauth plugin'
  description 'This plugin adds Omniauth support to Redmine'
  author 'Jean-Baptiste BARTH'
  author_url 'mailto:jeanbaptiste.barth@gmail.com'
  url 'https://github.com/jbbarth/redmine_omniauth_cas'
  version '3.3.0'
  requires_redmine :version_or_higher => '2.0.0'
  requires_redmine_plugin :redmine_base_rspec, :version_or_higher => '0.0.3' if Rails.env.test?
  settings :default => { 'enabled' => 'true', 'label_login_with_cas' => '', 'cas_server' => '' },
           :partial => 'settings/omniauth_cas_settings'
end
