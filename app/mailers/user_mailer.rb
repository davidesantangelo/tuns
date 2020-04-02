# frozen_string_literal: true

class UserMailer < ActionMailer::Base
  layout 'mail'

  def unfollower(unfollower)
    @unfollower = unfollower
    @user = unfollower.user
    mail(from: "\"#{@unfollower.name} (via TUNS)\" <notify@tuns.it>",
         to: "#{@user.name} <#{@user.email}>",
         subject: "#{@unfollower.name} (@#{@unfollower.username}) has just unfollowed you on Twitter!",
         layout: 'mail')
  end

  def follower(follower)
    @follower = follower
    @user = follower.user
    mail(from: "\"#{@follower.name} (via TUNS)\" <notify@tuns.it>",
         to: "#{@user.name} <#{@user.email}>",
         subject: "#{@follower.name} (@#{@follower.username}) has just returned to follow you on Twitter!",
         layout: 'mail')
  end
end
