# frozen_string_literal: true

initializers_dir = File.join(Rails.root, "config", "initializers")
if Dir.glob(File.join(initializers_dir, "redmine_omniauth_cas.rb")).blank?
  $stderr.puts "Omniauth CAS Plugin: Missing initialization file config/initializers/redmine_omniauth_cas.rb. " \
                 "Please copy the provided file to the config/initializers/ directory.\n" \
                 "You can copy/paste this command:\n" \
                 "cp #{File.join(Rails.root, "plugins", "redmine_omniauth_cas")}/initializers/redmine_omniauth_cas.rb #{File.join(initializers_dir, "redmine_omniauth_cas.rb")}"
  exit 1
end

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
