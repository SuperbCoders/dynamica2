Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  get 'charts_data/full_chart_data'
  get 'charts_data/full_donut_chart_data'
  get 'charts_data/full_chart_check_points'
  get 'charts_data/big_chart_data'
  get 'charts_data/other_chart_data'
  get 'charts_data/sorted_full_chart_data'
  get 'charts_data/products_characteristics'

  apipie

  devise_for :users, skip: [:session, :password, :registration, :confirmation],
      controllers: { omniauth_callbacks: 'customized_devise/omniauth_callbacks' }

  namespace :draw do
    get 'block' => 'graph#block'
    get 'big' => 'graph#big'
    get 'donut' => 'graph#donut'
  end

  scope "(:locale)", locale: /en|ru/ do
    root 'welcome#index'
    get 'dashboard' => 'dashboard#index', as: :dashboard
    get 'templates(/*url)' => 'application#templates'
    get 'apidocs' => 'apidocs#index'

    devise_for :users, controllers: {
        registrations: 'customized_devise/registrations',
        sessions: 'customized_devise/sessions',
        passwords: 'customized_devise/passwords'
    }, skip: :omniauth_callbacks

    devise_scope :user do
      match 'users/avatar' => 'customized_devise/registrations#avatar', via: [:put, :patch]
    end

    scope :subscriptions do
      get 'callback' => 'subscriptions#callback', as: :subscription_callback
      get 'show' => 'subscriptions#show', as: :show_subscription
      post 'change' => 'subscriptions#change', as: :change_subscription
      post 'cancel' => 'subscriptions#cancel', as: :cancel_subscription
    end

    scope :profile do
      post 'email_uniqueness' => 'profile#email_uniqueness'
      get  '/' => 'profile#index', as: :profile
      post '/' => 'profile#update', as: :update

      scope :avatar do
        post 'destroy' => 'profile#avatar_destroy', as: :destroy_avatar
        post 'upload' => 'profile#avatar_upload', as: :upload_avatar
      end

    end

    resources :projects, defaults: { format: :json } do
      collection do
        post 'search' => 'projects#search'
      end
      member do
        get 'update_data' => 'projects#update_data'
      end
      resources :permissions, only: [:index, :update, :destroy], shallow: true, on: :member
      resources :pending_permissions, only: [:create, :destroy], on: :member
      resources :items, only: [:index, :create, :update, :destroy], on: :member do
        delete :values, on: :member
      end
      resources :forecasts, only: [:new, :create] do
        resources :predicted_values, only: :index
      end
      resources :attachments, only: :create
      get :full_chart, on: :member
    end

    resources :permissions, only: :index do
      get :activate, on: :member
    end
  end
end

load Rails.root.join 'config/routes/api.rb'
load Rails.root.join 'config/routes/admin.rb'
load Rails.root.join 'config/routes/third_party.rb'
