Rails.application.routes.draw do
  root to: 'welcome#index'

  # Mount Devise. But currently we do not need any of its routes
  devise_for :users, skip: [:sessions, :passwords, :registrations]

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
