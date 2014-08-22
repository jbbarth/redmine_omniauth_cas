require_dependency 'account_helper'

module Redmine::OmniAuthCAS
  module AccountHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      # Disabled for now in tests as it raises the following error with Rspec :
      #
      #   gems/activesupport-3.2.19/lib/active_support/dependencies.rb:663:in `to_constant_name':
      #     Anonymous modules have no name to be referenced by (ArgumentError)
      #
      # From what I've seen the code was working correctly previously with Test::Unit, and in
      # development mode and also in production mode.
      unless Rails.env.test?
        base.class_eval do
          unloadable
        end
      end
    end

    module InstanceMethods
      def label_for_cas_login
        Redmine::OmniAuthCAS.label_login_with_cas.presence || l(:label_login_with_cas)
      end
    end
  end
end

unless AccountHelper.included_modules.include? Redmine::OmniAuthCAS::AccountHelperPatch
  AccountHelper.send(:include, Redmine::OmniAuthCAS::AccountHelperPatch)
end
