class UserMailer < ActionMailer::Base
  before_filter :set_attachments
  default from: 'no-reply@tuns.it'

  layout 'mail'

  def unfollower_notification
  end

  private

  def set_attachments
  end
end