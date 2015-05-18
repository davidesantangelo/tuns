# app/workers/sync_worker.rb
class SyncWorker
  include Sidekiq::Worker

  def perform(user_id)
  	user = User.find(user_id)
    
    twitter_config =  YAML.load_file('config/twitter.yml')[Rails.env]
    twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = twitter_config['consumer_key']
      config.consumer_secret     = twitter_config['consumer_secret']
      config.access_token        = user.access_token
      config.access_token_secret = user.access_token_secret
    end

   	cursor = "-1"
    while cursor != 0 do
      begin
        limited_followers = twitter_client.follower_ids(cursor: cursor)
        limited_followers.attrs[:ids].each do |id|
          Follower.where(user_id: user.id, uid: id).first_or_create
        end
        cursor = limited_followers.attrs[:next_cursor]
      rescue Twitter::Error::TooManyRequests => error
        sleep error.rate_limit.reset_in + 1
        retry
      end
    end
  end
end