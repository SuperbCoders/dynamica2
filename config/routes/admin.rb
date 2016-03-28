Rails.application.routes.draw do
  namespace :admin do
    root 'dashboard#index'
    resources :users, except: :show
    resources :projects, only: [:index, :show]
  end
end
