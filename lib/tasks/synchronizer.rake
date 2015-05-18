namespace :synchronizer do
	task users: :environment do
    User.all.each do |user|
      twitter_config =  YAML.load_file('config/twitter.yml')[Rails.env]
      twitter_client = Twitter::REST::Client.new do |config|
        config.consumer_key        = twitter_config['consumer_key']
        config.consumer_secret     = twitter_config['consumer_secret']
        config.access_token        = user.access_token
        config.access_token_secret = user.access_token_secret
      end

      current_followers = Follower.all.map(&:uid)      
      new_followers = fetch_followers(twitter_client)

      new_elements, deleted_elements = comparelist(current_followers, new_followers)

      deleted_elements.each do |deleted_uid|
        Unfollower.where(user_id: user.id, uid: deleted_uid).first_or_create
      end
      
      new_elements.each do |new_uid|
        Unfollower.where(user_id: user.id, uid: new_uid).destroy_all
        Follower.where(user_id: user.id, uid: new_uid).first_or_create
      end
    end
  end

  def comparelist(old_list, new_list)
    deleted_elements = []
    new_elements = []

    diff = old_list - new_list | new_list - old_list
    diff.each do |d|
      if old_list.include? d 
        deleted_elements.push(d) 
      else
        new_elements.push(d)
      end
    end
    return new_elements, deleted_elements
  end

 	def fetch_followers(twitter_client)
    cursor = "-1"
    followers = []
    while cursor != 0 do
      begin
        limited_followers = twitter_client.follower_ids(cursor: cursor)
        limited_followers.attrs[:ids].each do |id|
         followers.push(id.to_s)
        end
        cursor = limited_followers.attrs[:next_cursor]
      rescue Twitter::Error::TooManyRequests => error
        sleep error.rate_limit.reset_in + 1
        retry
      end
    end
    return followers
  end
end