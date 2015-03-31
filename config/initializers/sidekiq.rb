redis_config = YAML.load_file("#{Rails.root}/config/redis.yml")[Rails.env]
namespace = "dynamica_#{Rails.env}"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_config['url'], namespace: namespace }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_config['url'], namespace: namespace }
end