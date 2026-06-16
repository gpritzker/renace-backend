require "openssl"

redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/0").strip

redis_config = { url: redis_url }

if redis_url.start_with?("rediss://")
  redis_config[:ssl] = true
  # No usar VERIFY_NONE en producción — verificar el certificado del servidor Redis
  # Render provee certificados válidos; si usás Redis propio asegurate de tener CA correcta
  redis_config[:ssl_params] = Rails.env.production? ? {} : { verify_mode: OpenSSL::SSL::VERIFY_NONE }
end

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
