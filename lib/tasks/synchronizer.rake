namespace :synchronizer do
	task users: :environment do
  end

 	def sync_followers
    cursor = "-1"
    while cursor != 0 and valid_request? do
      begin
        limited_followers = @twitter_client.followers(current_user.username, {cursor: cursor} )
        Request.create(user_id: current_user.id, resource: 'followers')
        limited_followers.attrs[:users].each do |follower|
          Follower.where(user_id: current_user.id, username: follower[:screen_name]).first_or_create
        end
        cursor = limited_followers.attrs[:next_cursor]
      rescue Twitter::Error::TooManyRequests => error
        sleep error.rate_limit.reset_in + 1
        retry
      end
    end
  end
end