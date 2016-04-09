REDIS_DB = 9
if Rails.env.development? or Rails.env.test?
  $redis = Redis.new(db: REDIS_DB)
else
  $redis = Redis.new(host: '89.208.147.167', port: 6379, db: REDIS_DB)
end

