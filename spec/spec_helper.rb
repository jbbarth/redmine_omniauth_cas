# Load the normal Rails helper
require 'spec_helper'

# Mock CAS server
OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:cas] = OmniAuth::AuthHash.new({
                                                           'provider' => 'cas',
                                                           'uid' => 'test_user',
                                                           'info' => { 'email' => 'test_user@example.com' }
                                                         })