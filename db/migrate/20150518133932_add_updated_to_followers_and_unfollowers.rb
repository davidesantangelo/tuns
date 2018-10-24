class AddUpdatedToFollowersAndUnfollowers < ActiveRecord::Migration[5.2]
  def change
  	add_column :followers, :updated, :boolean, default: false
  	add_column :unfollowers, :updated, :boolean, default: false
  end
end
