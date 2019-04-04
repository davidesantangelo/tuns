class CreateUnfollowers < ActiveRecord::Migration[5.2]
  def change
    create_table :unfollowers do |t|
    	t.references :user, index: true, foreign_key: true, dependent: :delete
    	t.string :uid
    	t.string :username
    	t.string :name
    	t.string :description
    	t.string :profile_image_url
      t.timestamps null: false
    end
    add_index :unfollowers, [:user_id, :uid], unique: true
  end
end
