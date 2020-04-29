# frozen_string_literal: true

# app/workers/sync_worker.rb
class SyncWorker
  include Sidekiq::Worker

  def perform(user_id)
    user = User.find(user_id)
    twitter_client = TwitterClient.build(user)

    cursor = '-1'
    while cursor != 0
      begin
        limited_followers = twitter_client.follower_ids(cursor: cursor)
        limited_followers.attrs[:ids].each do |id|
          Follower.where(user_id: user.id, uid: id).first_or_create
        end
        cursor = limited_followers.attrs[:next_cursor]
      rescue Twitter::Error::TooManyRequests => e
        sleep e.rate_limit.reset_in + 1
        retry
      end
    end
  end
end
