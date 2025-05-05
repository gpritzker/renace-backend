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
               confirmations: 'api/v1/confirmations'
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
    resources :users
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
      resources :capsules, only: [:index, :show, :create, :update]
      resources :memories, only: [:index, :create, :update]  
    end
  end

  # =========================
  # 🌐 Root general (redirige a login admin)
  # =========================
  root to: 'admin/sessions#new'
end