Apipie.configure do |config|
  config.app_name                = "Dynamica"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/apidocs"
  config.default_version         = 'v1'
  config.markup                  = Apipie::Markup::Markdown.new
  config.validate                = false
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
end
