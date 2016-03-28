Rails.application.routes.draw do
  namespace :third_party do
    namespace :shopify do
      match 'install' => 'installation#index', via: [:get, :post]
      match 'oauth/callback' => 'oauth#callback', via: [:get, :post], as: :oauth_callback
    end
  end
end
