require_relative "boot"
require "rails/all"
require "logger"
require "active_support/logger"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Renace
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    Dotenv::Railtie.load if defined?(Dotenv)

    # Only loads a smaller set of middleware suitable for API only apps.
    config.api_only = true

    # Use Sidekiq for background jobs
    config.active_job.queue_adapter = :sidekiq

    # Middleware for CORS (used by frontend to access backend)
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*',
                 headers: :any,
                 expose: ['Authorization'],
                 methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end

    # Ensure logger is available and safe
    config.logger = Logger.new($stdout)
    config.log_level = :debug
  end
end