Rails.application.config.action_dispatch.default_headers = {
  'X-Frame-Options'        => 'DENY',
  'X-Content-Type-Options' => 'nosniff',
  'X-XSS-Protection'       => '0',               # Deshabilitar XSS Auditor legacy (CSP lo reemplaza)
  'Referrer-Policy'         => 'strict-origin-when-cross-origin',
  'Permissions-Policy'      => 'camera=(), microphone=(self), geolocation=()',
  'Content-Security-Policy' => [
    "default-src 'self'",
    "script-src 'self'",
    "style-src 'self' 'unsafe-inline'",           # unsafe-inline necesario para Tailwind inline
    "img-src 'self' data: https://*.amazonaws.com",
    "media-src 'self' https://*.amazonaws.com",
    "font-src 'self'",
    "connect-src 'self' https://api.mercadopago.com",
    "frame-ancestors 'none'",
    "form-action 'self'",
    "base-uri 'self'"
  ].join('; ')
}

# HSTS se configura en el middleware de force_ssl en production.rb
