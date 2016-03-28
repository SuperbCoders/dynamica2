source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.8'
# Use postgres as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
gem 'less-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

# JS libraries
gem 'jquery-rails'
gem 'airbrussh'
gem 'bower-rails'

# CSS libraries
gem 'compass-rails'
gem "font-awesome-rails"
gem 'bootstrap-sass', '~> 3.3.1'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
gem 'unicorn'

gem 'groupdate'

# Use Capistrano for deployment
group :development do
  gem 'capistrano', '3.3.4'
  gem 'capistrano-rvm'
  gem 'capistrano-rails'
  gem 'capistrano3-unicorn'
  gem 'capistrano-sidekiq'

  gem 'annotate', '~> 2.6.10'


  gem 'better_errors', '~> 2.1.1'
  gem 'binding_of_caller', '~> 0.7.2'
  gem 'pry-rails', '~> 0.3.3'
end

# Use debugger
# gem 'debugger', group: [:development, :test]

group :development, :test do
  gem 'quiet_assets', '~> 1.1.0'

  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'capybara'

  # Uncomment to use Poltergeist
  gem 'poltergeist'
  gem 'database_cleaner'

  # Uncomment to use Selenium
  # gem 'selenium-webdriver'
end

# Use letter opener for test emails
gem 'letter_opener', group: :development

# REST API generation tool
gem 'apipie-rails'
gem 'maruku'

gem 'devise'
gem 'cancancan'
gem 'rabl'
gem 'oj'
gem 'workflow'
# Commented temporary
# gem 'rinruby'
gem 'whenever'
gem 'slim-rails'
gem 'active_model_serializers', '~> 0.10.0.rc4'
gem 'simple_form'
gem 'friendly_id', '~> 5.0.0'
gem 'carrierwave'
gem 'mini_magick'
gem 'jquery-fileupload-rails'
gem 'non-stupid-digest-assets', '~> 1.0.4' # creates both digest and non-digest assets
gem 'settingslogic'

gem 'haml-rails'
gem 'haml'

source 'https://rails-assets.org' do
  gem 'rails-assets-d3'
  gem 'rails-assets-moment'
  gem 'rails-assets-select2'
  # gem 'rails-assets-bootstrap-select'
end

# Admin panel
gem 'first_admin_panel', git: 'git@bitbucket.org:ImmaculatePine/first_admin_panel.git'
gem 'kaminari'
gem 'bootstrap-kaminari-views'

# CSV libraries
gem 'smarter_csv' # For reading
gem 'render_csv'  # For export
gem 'airbrussh'
gem 'rubyzip'
gem 'russian'
gem 'celluloid', '~> 0.16.0'
gem 'sidekiq'
gem 'sidetiq', '~> 0.6.3'

# Third-party shops integration
gem 'activeresource', git: 'git://github.com/Shopify/activeresource', tag: '4.2-threadsafe'
gem 'shopify_api', '>= 3.2.1'
