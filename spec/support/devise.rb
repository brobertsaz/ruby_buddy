# frozen_string_literal: true

# Ensure Devise is properly configured for tests
Warden.test_mode!

RSpec.configure do |config|
  config.after(:each) do
    Warden.test_reset!
  end
end
