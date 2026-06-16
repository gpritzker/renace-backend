require 'sidekiq/web'

Rails.application.routes.draw do
  # Sidekiq UI — protegido por Basic Auth, acceso solo desde IPs admin idealmente
  Sidekiq::Web.use(Rack::Auth::Basic) do |user, pass|
    user == ENV.fetch('SIDEKIQ_USER', 'admin') &&
      ActiveSupport::SecurityUtils.secure_compare(
        pass,
        ENV.fetch('SIDEKIQ_PASSWORD') { raise 'SIDEKIQ_PASSWORD env var is required' }
      )
  end
  mount Sidekiq::Web => '/sidekiq'

  # ── API Auth (JWT + Devise) ───────────────────────────────────────────────
  devise_for :users,
             defaults: { format: :json },
             path: '',
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               registration: 'signup'
             },
             controllers: {
               sessions: 'api/v1/sessions',
               registrations: 'api/v1/registrations',
               confirmations: 'api/v1/confirmations',
               passwords: 'api/v1/passwords'
             }

  # ── Admin Backoffice (session-based) ─────────────────────────────────────
  devise_scope :user do
    get    'admin/login',  to: 'admin/sessions#new',    as: :new_admin_session
    post   'admin/login',  to: 'admin/sessions#create', as: :admin_session
    delete 'admin/logout', to: 'admin/sessions#destroy', as: :destroy_admin_session
  end

  namespace :admin do
    get 'dashboard', to: 'dashboard#index'
    root to: 'dashboard#index'

    resources :users do
      member do
        patch :confirm
        patch :toggle_premium
      end
    end
    resources :capsules do
      member do
        patch :approve
        patch :disapprove
      end
    end
    resources :memories

    resources :audit_logs, only: [:index]
  end

  # ── API v1 ────────────────────────────────────────────────────────────────
  namespace :api do
    namespace :v1 do
      resources :capsules, only: [:index, :show, :create, :update, :destroy]
      resources :memories, only: [:index, :show, :create, :update, :destroy]

      # Endpoints públicos (sin auth — tienen rate limiting via Rack::Attack)
      get  'public/capsules/:id',               to: 'public_capsules#show'
      post 'public/capsules/:id/narrate',        to: 'public_capsules#narrate'
      post 'public/capsules/:id/narrate_story',  to: 'public_capsules#narrate_story'

      # Bot conversacional público
      post 'capsules/:capsule_id/chat', to: 'conversations#chat'

      # Perfil de usuario
      get   'profile', to: 'profile#show'
      patch 'profile', to: 'profile#update'

      # Billing
      post 'billing/checkout', to: 'billing#checkout'
      post 'billing/cancel',   to: 'billing#cancel'

      # Voz e IA
      get    'voice_profile',         to: 'voice_profiles#show'
      post   'voice_samples',         to: 'voice_profiles#create_sample'
      delete 'voice_samples/:id',     to: 'voice_profiles#destroy_sample', as: :voice_sample
      post   'voice_profile/clone',   to: 'voice_profiles#clone'
      post   'voice_profile/preview', to: 'voice_profiles#preview'

      # 2FA
      get    'two_factor/setup', to: 'two_factor#setup'
      post   'two_factor/enable', to: 'two_factor#enable'
      delete 'two_factor',        to: 'two_factor#destroy'
    end
  end

  # ── Webhooks (públicos con verificación de firma) ─────────────────────────
  post '/webhooks/mercadopago', to: 'webhooks/mercado_pago#receive'

  root to: 'admin/sessions#new'
end
