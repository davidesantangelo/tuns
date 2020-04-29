# frozen_string_literal: true

class Notification
  def self.send(unfollower)
    client = TwitterClient.build(User.system)

    client.update("hi @#{unfollower.user.slug} someone has just unfollowed you on Twitter! Check on tunsapp.com")
  rescue StandardError
    false
  end
end
