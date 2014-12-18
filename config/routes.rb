Rails.application.routes.draw do
  root to: 'welcome#index'

  devise_for :users, controllers: { registrations: 'customized_devise/registrations', sessions: 'customized_devise/sessions', passwords: 'customized_devise/passwords' }

  resources :projects do
    resources :permissions, only: [:index, :update, :destroy], shallow: true, on: :member
    resources :pending_permissions, only: [:create, :destroy], on: :member
    resources :items, only: [:index, :create, :destroy], on: :member
    resources :attachments, only: :create
  end

  resources :permissions, only: [] do
    get :activate, on: :member
  end

  namespace :api do
    namespace :v1 do
      resources :projects, only: [] do
        resources :values, only: :create
        resources :items, only: [] do
          resources :forecasts, only: [:index, :create]
          delete :values, on: :member
        end
      end
      resources :forecasts, only: [] do
        resources :predicted_values, only: :index
      end
    end
  end
end
