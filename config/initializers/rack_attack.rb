class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
    error_handler: ->(method:, returning:, exception:) {
      Rails.logger.error "Rack::Attack Redis error (#{method}): #{exception.message}"
    }
  )

  # ── Throttles ──────────────────────────────────────────────────────────────

  # Login: 5 intentos por IP por 20 segundos
  throttle('login/ip', limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == '/login' && req.post?
  end

  # Login: 10 intentos por email por 5 minutos (credential stuffing)
  throttle('login/email', limit: 10, period: 5.minutes) do |req|
    if req.path == '/login' && req.post?
      body = req.body.read
      req.body.rewind
      email = JSON.parse(body).dig('user', 'email').to_s.downcase.strip rescue nil
      email.presence
    end
  end

  # Registro: 3 por IP por hora
  throttle('signup/ip', limit: 3, period: 1.hour) do |req|
    req.ip if req.path == '/signup' && req.post?
  end

  # Password reset: 5 por IP por hora
  throttle('password_reset/ip', limit: 5, period: 1.hour) do |req|
    req.ip if req.path.include?('/password') && req.post?
  end

  # Narración pública con AI: costosa, limitar agresivamente
  throttle('narrate/ip', limit: 10, period: 1.hour) do |req|
    req.ip if req.path.match?(%r{/api/v1/public/capsules/\d+/narrate}) && req.post?
  end

  # Chat con IA: 30 mensajes por IP por hora
  throttle('chat/ip', limit: 30, period: 1.hour) do |req|
    req.ip if req.path.match?(%r{/api/v1/capsules/\d+/chat}) && req.post?
  end

  # API general: 300 requests por minuto por IP
  throttle('api/ip', limit: 300, period: 1.minute) do |req|
    req.ip if req.path.start_with?('/api/')
  end

  # ── Blocklist ──────────────────────────────────────────────────────────────

  blocklist('block bad user agents') do |req|
    ua = req.user_agent.to_s.downcase
    ua.include?('sqlmap') || ua.include?('nikto') || ua.include?('nessus') || ua.include?('masscan')
  end

  # ── Respuesta personalizada ────────────────────────────────────────────────

  self.throttled_responder = lambda do |req|
    match_data = req.env['rack.attack.match_data']
    retry_after = (match_data[:period] - (Time.now.to_i % match_data[:period])).to_s

    [
      429,
      {
        'Content-Type' => 'application/json',
        'Retry-After' => retry_after
      },
      [{ error: 'Demasiadas solicitudes. Intentá más tarde.', retry_after: retry_after }.to_json]
    ]
  end
end
