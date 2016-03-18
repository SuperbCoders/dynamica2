Rails.application.routes.draw do
  get 'templates(/*url)' => 'application#templates'
  get 'charts_data/full_chart_data'
  get 'charts_data/big_chart_data'
  get 'charts_data/other_chart_data'
  get 'charts_data/sorted_full_chart_data'

  apipie

  scope "(:locale)", locale: /en|ru/ do
    root 'welcome#index'

    get 'apidocs' => 'apidocs#index'

    devise_for :users, controllers: { registrations: 'customized_devise/registrations', sessions: 'customized_devise/sessions', passwords: 'customized_devise/passwords' }
    devise_scope :user do
      match 'users/avatar' => 'customized_devise/registrations#avatar', via: [:put, :patch]
    end

    get 'dashboard' => 'dashboard#index', as: :dashboard

    scope :profile do
      get  '/' => 'profile#index', as: :profile
      post '/' => 'profile#update', as: :update
    end


    resources :projects, defaults: { format: :json } do
      collection do
        post 'search' => 'projects#search'
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

  namespace :api do
    namespace :v1 do
      resources :projects, only: [] do
        resources :forecasts, only: [:index, :create] do
          resources :forecast_lines, only: :index, path: :lines
        end

        resources :values, only: :create

        resources :items, only: [] do
          resources :values, only: :create do
            delete '' => 'values#destroy_all', on: :collection
          end
        end

      end
      resources :forecasts, only: [] do
        resources :forecast_lines, only: :index, path: :lines
      end
    end
  end

  namespace :admin do
    root 'dashboard#index'
    resources :users, except: :show
    resources :projects, only: [:index, :show]
  end

  namespace :third_party do
    namespace :shopify do
      match 'install' => 'installation#index', via: [:get, :post]
      match 'oauth/callback' => 'oauth#callback', via: [:get, :post], as: :oauth_callback
    end
  end
end
