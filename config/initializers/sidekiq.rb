# config/initializers/sidekiq.rb
require "uri"
require "openssl"

redis_uri = URI.parse(ENV.fetch("REDIS_URL"))

redis_config = {
  host: redis_uri.host,
  port: redis_uri.port,
  username: redis_uri.user,
  password: redis_uri.password,
  ssl: redis_uri.scheme == "rediss",
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
}

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end