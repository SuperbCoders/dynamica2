Rails.application.routes.draw do
  apipie
  root to: 'welcome#index'

  devise_for :users, controllers: { registrations: 'customized_devise/registrations', sessions: 'customized_devise/sessions', passwords: 'customized_devise/passwords' }
  devise_scope :user do
    match 'users/avatar' => 'customized_devise/registrations#avatar', via: [:put, :patch]
  end

  resources :projects do
    resources :permissions, only: [:index, :update, :destroy], shallow: true, on: :member
    resources :pending_permissions, only: [:create, :destroy], on: :member
    resources :items, only: [:index, :create, :update, :destroy], on: :member do
      delete :values, on: :member
    end
    resources :forecasts, only: [:new, :create] do
      resources :predicted_values, only: :index
    end
    resources :attachments, only: :create
  end

  resources :permissions, only: [] do
    get :activate, on: :member
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
end
