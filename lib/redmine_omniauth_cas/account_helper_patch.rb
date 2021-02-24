require_dependency 'account_helper'

module Redmine::OmniAuthCAS
  module AccountHelperPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
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
