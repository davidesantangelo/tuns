class UserMailer < ActionMailer::Base
  before_filter :set_attachments

  layout 'mail'

  def unfollower(unfollower)
  	@unfollower = unfollower
  	@user = unfollower.user
   	mail( from: "\"#{@unfollower.name} (via TUNS)\" <notify@tuns.it>" , 
          to: "#{@user.name} <#{@user.email}>",
   				subject: "#{@unfollower.name} (@#{@unfollower.username}) is now unfollowing you on Twitter!", 
   				layout: "mail")
  end

  private

  def set_attachments
  end
end