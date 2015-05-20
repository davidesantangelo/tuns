class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :followers do |t|
    	t.references :user, index: true, foreign_key: true, dependent: :delete
    	t.string :uid
    	t.string :username
    	t.string :name
    	t.string :description
    	t.string :profile_image_url
      t.timestamps null: false
    end
    add_index :followers, [:user_id, :uid], unique: true
  end
end
