# Redmine OmniAuth CAS plugin

This plugins adds CAS authentication support for [Redmine](http://www.redmine.org) thanks to the [OmniAuth authentication framework](https://github.com/intridea/omniauth). OmniAuth is a Rack middleware that let you authenticate against many sources (see [the list of supported sources](https://github.com/intridea/omniauth/blob/master/README.md)). This plugin aims at being an example of integration for the CAS protocol, but it shouldn't be that difficult to build a plugin that allows authentication against other sources.

*NB*: the plugin doesn't support on-the-fly registration for now.

## Install

You can first take a look at general instructions for plugins [here](http://www.redmine.org/wiki/redmine/Plugins)

Note that the plugin is now *only compatible with Redmine 2.0.0 or higher*. Compatibility with Redmine 1.x has been removed in August, 2012.

Then :
* clone this repository in your plugins/ directory ; if you have a doubt you put it at the good level, you can go to your redmine root directoryand check you have a @plugins/redmine_omniauth_cas/init.rb@ file
* install the dependencies with bundler : `bundle install`
* copy assets by running this command from your redmine root directory (note: the plugin has no migration for now) : `RAILS_ENV=production rake redmine:plugins`
* copy `initializers/redmine_omniauth_cas.rb` to `${REDMINE}/config/initializers/redmine_omniauth_cas.rb`
* restart your Redmine instance (depends on how you host it)

Finally you can configure your CAS server URL directly in your redmine instance, in "Administration" > "Plugins" > "Configure" on the OmniAuth CAS plugin line.

## Coming soon features

Here are some ideas that could be implemented in future releases. I'm really open to suggestions on this plugin, so don't hesitate to fill an issue directly on GitHub :
* implement ticket validation when first opening your browser (for now you’ll be considered as logged out if your session has expired on Redmine but your ticket is still valid on the CAS server)
* add a plugin option to hide 'normal' login/password form
* authorize on-the-fly registration
* authorize non-conventional CAS URLs (for now you can just specify the base CAS url, and login, logout, validate, etc. URLs are deduced)

## Internals

### Why not use the AuthSource Redmine system ?

From a functionality point of view, Redmine's AuthSource system is useful for 2 things :
* you want to be able to define multiple occurrences of the same authentication source => not possible afaik with OmniAuth CAS strategy
* you want to restrict users to a certain auth source => not so interesting if the login is filled in an external form

Actually, OpenID authentication in core is not an AuthSource neither.

### Why is there a default on http://localhost:9292/ everywhere ?

There are some limitations with the current implementation of OmniAuth CAS strategy. To be clear, it doesn't support dynamic parameters very well, and forces to have a default :cas_server or :cas_login_url defined in the initialization process. I hope I'll have the time to propose a fix or develop my own CAS strategy soon.

## Contribute

If you like this plugin, it's a good idea to contribute :
* by giving feed back on what is cool, what should be improved
* by reporting bugs : you can open issues directly on github for the moment
* by forking it and sending pull request if you have a patch or a feature you want to implement

## Changelog

### master/current

* Fix: avoid potential errors when "service_validate" option is not set in plugin configuration, leading to 500 error after CAS redirect
* Fix: correctly update User#last_login_on when authenticating through CAS
* Fix: disable SSL certificate verification since it's totally broken
* Fix: repare different url for validation
* Feature: upgrade to OmniAuth 1.x and Redmine 2.x
* Feature: clean log out from CAS for users logged in through CAS
* Feature: supported Redmine 5.x

### v0.1.2

* Feature: allow having a different host for ticket validation (think: internet redirect for user's login, but ticket validation done through internal URL)

### v0.1.1

* Fix: avoid potential 500 error with some CAS servers when using the (bad) default :cas_server option
* Fix: do not show CAS button on login page if CAS URL is not set
* Fix: bad default :cas_server URL, lead to malformed '/login' URL not supported by rubycas-server

### v0.1.0 (first release)

* Feature: upgrade to Redmine >= 1.2.0, since the latest versions of OmniAuth do not support Rack 1.0.1
* Feature: provide a link to logout from CAS completely if username doesn't exist in redmine
* Feature: make the CAS server URL configurable
* Feature: provide a way to override standard text on login page
* Feature: configure OmniAuth 'full_host' in case the application runs behing a reverse-proxy
* Feature: basic CAS login

## Test status

|Plugin branch| Redmine Version | Test Status       |
|-------------|-----------------|-------------------|
|master       | 6.0.5           | [![6.0.5][1]][5]  |
|master       | 5.1.8           | [![5.1.8][2]][5]  |
|master       | master          | [![master][4]][5] |

[1]: https://github.com/jbbarth/redmine_omniauth_cas/actions/workflows/6_0_5.yml/badge.svg
[2]: https://github.com/jbbarth/redmine_omniauth_cas/actions/workflows/5_1_8.yml/badge.svg
[4]: https://github.com/jbbarth/redmine_omniauth_cas/actions/workflows/master.yml/badge.svg
[5]: https://github.com/jbbarth/redmine_omniauth_cas/actions

## License

This project is released under the MIT license, see LICENSE file.
