ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors, with: :threads)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

# Set modern browser User-Agent for all integration tests so allow_browser doesn't block with 406
class ActionDispatch::IntegrationTest
  MODERN_USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"

  setup do
    @default_ua_headers = { "User-Agent" => MODERN_USER_AGENT }
  end

  %i[get post patch put delete].each do |method|
    define_method(method) do |path, **kwargs|
      kwargs[:headers] = (@default_ua_headers || {}).merge(kwargs[:headers] || {})
      super(path, **kwargs)
    end
  end
end

