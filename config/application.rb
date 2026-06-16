require_relative "boot"
require "rails/all"
require "logger"
require "active_support/logger"
require "sprockets/railtie"
require 'dotenv-rails'
require "active_storage/engine"

Bundler.require(*Rails.groups)

module Renace
  class Application < Rails::Application
    config.load_defaults 7.0

    Dotenv::Railtie.load if defined?(Dotenv)

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Flash
    config.middleware.use ActionDispatch::Session::CookieStore, {
      key: '_renace_session',
      secure: Rails.env.production?,
      httponly: true,
      same_site: :lax
    }

    config.active_storage.service = :amazon
    config.active_job.queue_adapter = :sidekiq

    config.middleware.use Rack::Attack

    config.logger = Logger.new($stdout)
    config.log_level = Rails.env.production? ? :info : :debug

    # Filtrar parámetros sensibles de los logs
    config.filter_parameters += [
      :password, :password_confirmation, :token, :secret, :key,
      :credit_card, :cvv, :access_token, :refresh_token, :jti,
      :encrypted_password, :reset_password_token, :confirmation_token,
      :mp_subscription_id, :elevenlabs_voice_id
    ]
  end
end
