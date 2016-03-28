Rails.application.routes.draw do
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
