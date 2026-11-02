# frozen_string_literal: true

module RedmineOmniauthCas
  module ApplicationControllerPatch
    extend ActiveSupport::Concern

    # Ignores the scheme and port of the url, which differ behind a reverse proxy,
    # and leaves every other check to the core method
    def validate_back_url(back_url)
      return false if back_url.blank? || !back_url.is_a?(String)

      uri = Addressable::URI.parse(back_url)
      return false if uri.host.present? && uri.host != request.host

      super(uri.omit(:scheme, :authority).to_s)
    rescue Addressable::URI::InvalidURIError
      false
    end

  end
end

ApplicationController.prepend RedmineOmniauthCas::ApplicationControllerPatch
