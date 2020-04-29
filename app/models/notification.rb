class Notification
  def self.send(unfollower)
    begin
      client = TwitterClient.build(User.system)
      
      client.update("hi @#{unfollower.user.slug} someone has just unfollowed you on Twitter! Check on tunsapp.com")
    rescue StandardError
      false
    end
  end
end