namespace :users do
  task lookup: :environment do
    logger = Logger.new('log/lookup.log')
    logger.info ("STARTED")
    Unfollower.where(updated: false).each do |unfollower|
      begin
        twitter_client = client(unfollower.user)
        user = twitter_client.user(unfollower.uid.to_i)
        unfollower.update_attributes(username: user.screen_name, name: user.name, description: user.description, profile_image_url: user.profile_image_url, updated: true)
        UserMailer.unfollower(unfollower).deliver_now if (unfollower.user.email_verified? and unfollower.user.notification)
      rescue Exception => e
        logger.error "ERROR UNFOLLOWER: #{unfollower.id} MSG: #{e.message}"
        next
      end
    end
  end

  task unfollowers: :environment do
    logger = Logger.new('log/unfollowers.log')
    logger.info ("STARTED")
    User.where("email NOT LIKE 'change@me-%'").each do |user|

      if user.extra.followers_count >= 75000
        next
      end

      begin
        twitter_client = client(user)

        old_followers = user.followers.map(&:uid)
        new_followers = fetch_followers(twitter_client)
        new_elements, deleted_elements = comparelist(old_followers, new_followers)

        deleted_elements.each do |deleted_uid|
          # move the follower to the unfollowers table
          Follower.where(user_id: user.id, uid: deleted_uid).destroy_all
          unfollower = Unfollower.where(user_id: user.id, uid: deleted_uid).first_or_create

          twitter_user = twitter_client.user(unfollower.uid.to_i)
          unfollower.update_attributes(username: twitter_user.screen_name, name: twitter_user.name, description: twitter_user.description, profile_image_url: twitter_user.profile_image_url, updated: true)
          UserMailer.unfollower(unfollower).deliver_now if (user.email_verified? and user.notification)
        end

        new_elements.each do |new_uid|
          # move the unfollower to the followers table
          unfollowers = Unfollower.where(user_id: user.id, uid: new_uid)
          follower = Follower.where(user_id: user.id, uid: new_uid).first_or_create
         
          if not unfollowers.empty?
            unfollowers.destroy_all
            lookup = twitter_client.user(new_uid.to_i)
            follower.update_attributes(username: lookup.screen_name, name: lookup.name, description: lookup.description, profile_image_url: lookup.profile_image_url, updated: true)
            UserMailer.follower(follower).deliver_now if (follower.user.email_verified? and follower.user.notification)
          end
        end
      rescue Exception => e  
        logger.error "ERROR USER: #{user.id} MSG: #{e.message}"
        next
      end
    end
    logger.info ("STOPPED")
  end

  def client(user)
    twitter_config =  YAML.load_file('config/twitter.yml')[Rails.env]
    twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = twitter_config['consumer_key']
      config.consumer_secret     = twitter_config['consumer_secret']
      config.access_token        = user.access_token
      config.access_token_secret = user.access_token_secret
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
    cursor = '-1'
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
    followers
  end
end
