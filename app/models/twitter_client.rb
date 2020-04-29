class TwitterClient
  def self.build(user)
    twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV.fetch('TW_APP_ID')
      config.consumer_secret     = ENV.fetch('TW_APP_SECRET')
      config.access_token        = user.access_token
      config.access_token_secret = user.access_token_secret
    end
    
    twitter_client
  end