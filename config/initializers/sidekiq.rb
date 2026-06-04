# config/initializers/sidekiq.rb
require "openssl"

redis_config = {
  url: ENV.fetch("REDIS_URL"),
  ssl: true,
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
}

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end