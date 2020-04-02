# frozen_string_literal: true

class Unfollower < ActiveRecord::Base
  belongs_to :user
  default_scope { order('created_at DESC') }
  scope :updated, -> { where(updated: true) }
end
