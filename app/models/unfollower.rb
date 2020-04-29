# frozen_string_literal: true

class Unfollower < ActiveRecord::Base
  # relations
  belongs_to :user

  # scopes
  default_scope { order('created_at DESC') }
  scope :updated, -> { where(updated: true) }

  # callbacks
  after_create :send_notification

  def send_notification
    return unless user.notification

    Notification.send(self)
  end
end
