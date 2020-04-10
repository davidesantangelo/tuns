# frozen_string_literal: true

class Follower < ActiveRecord::Base
  belongs_to :user
end
