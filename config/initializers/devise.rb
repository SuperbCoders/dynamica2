# Use this hook to configure devise mailer, warden hooks and so forth.
# Many of these configuration options can be set straight in your model.
Devise.setup do |config|
  require 'devise/orm/active_record'

  config.omniauth :facebook,  ENV['facebook_app_id'], ENV['facebook_app_secret'],
      scope: 'email,public_profile,user_birthday',display: 'page', info_fields: 'id,email,first_name,last_name'

  config.omniauth :google_oauth2, ENV['google_client_id'], ENV['google_client_secret'],
      scope: 'email, profile'

  config.secret_key = '25bb207918c0a8c3ce293950afef276cbcc87b3099d68902f02ae4108b902d72e8fa60cd1e7e44fdaf5b69d82428ac3e31ed3f85666fde5ce8ce03b09018404c'
  config.mailer_sender = 'noreply@dynamica.cc'
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 10
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 8..128
  config.reset_password_within = 6.hours
  config.sign_out_via = :get
  config.navigational_formats = ["*/*", :html, :json]
end
