ForestAdminRails.configure do |config|
  config.auth_secret = ENV['FOREST_AUTH_SECRET']
  config.env_secret = ENV['FOREST_ENV_SECRET']
end
