require 'sidekiq/web'
Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  # =========================
  # 🔐 API AUTH - JWT + Devise
  # =========================
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

  # =========================
  # 🛠️ Admin Backoffice - HTML (Login manual)
  # =========================
  devise_scope :user do
    get    'admin/login',  to: 'admin/sessions#new',     as: :new_admin_session
    post   'admin/login',  to: 'admin/sessions#create',  as: :admin_session
    delete 'admin/logout', to: 'admin/sessions#destroy', as: :destroy_admin_session
  end

  namespace :admin do
    # Panel principal del admin
    get 'dashboard', to: 'dashboard#index'
    root to: 'dashboard#index'

    # Recursos del backoffice
    resources :users do
      member { patch :confirm }
    end
    resources :capsules do
      member do
        patch :approve
        patch :disapprove
      end
    end
    resources :memories
  end

  # =========================
  # 📦 API Recursos
  # =========================
  namespace :api do
    namespace :v1 do
      resources :capsules, only: [:index, :show, :create, :update, :destroy]
      resources :memories, only: [:index, :show, :create, :update, :destroy]

      # Endpoints públicos (sin auth)
      get  'public/capsules/:id',                  to: 'public_capsules#show'
      post 'public/capsules/:id/narrate',          to: 'public_capsules#narrate'
      post 'public/capsules/:id/narrate_story',    to: 'public_capsules#narrate_story'

      # Bot conversacional (público)
      post 'capsules/:capsule_id/chat', to: 'conversations#chat'

      # Perfil de voz e IA
      get    'voice_profile',         to: 'voice_profiles#show'
      post   'voice_samples',         to: 'voice_profiles#create_sample'
      delete 'voice_samples/:id',     to: 'voice_profiles#destroy_sample', as: :voice_sample
      post   'voice_profile/clone',   to: 'voice_profiles#clone'
      post   'voice_profile/preview', to: 'voice_profiles#preview'
    end
  end

  # =========================
  # 🌐 Root general (redirige a login admin)
  # =========================
  root to: 'admin/sessions#new'
end