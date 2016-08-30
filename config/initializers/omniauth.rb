Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['facebook_app_id'], ENV['facebook_secret']
  provider :twitter, ENV['twitter_consumer_key'], ENV['twitter_consumer_secret']
end
