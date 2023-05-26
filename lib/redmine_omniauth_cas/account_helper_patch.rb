require_dependency 'account_helper'

module AccountHelper
  def label_for_cas_login
    RedmineOmniauthCas.label_login_with_cas.presence || l(:label_login_with_cas)
  end
end
