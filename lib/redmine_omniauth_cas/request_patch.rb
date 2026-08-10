# frozen_string_literal: true

module RedmineOmniauthCas
  # The reverse proxy forwards requests in plain http, so urls rebuilt from the request
  # would send users back out of https
  module RequestPatch
    def original_url
      super.sub(/\Ahttp:/, "#{Setting.protocol}:")
    end
  end
end

ActionDispatch::Request.prepend RedmineOmniauthCas::RequestPatch
