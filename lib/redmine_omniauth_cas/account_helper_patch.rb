require_dependency 'account_helper'

module RedmineOmniauthCas::AccountHelperPatch
  def label_for_cas_login
    RedmineOmniauthCas.label_login_with_cas.presence || l(:label_login_with_cas)
  end
end

AccountHelper.prepend RedmineOmniauthCas::AccountHelperPatch
ActionView::Base.prepend AccountHelper
