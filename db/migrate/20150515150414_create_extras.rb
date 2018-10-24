class CreateExtras < ActiveRecord::Migration[5.2]
  def change
    create_table :extras do |t|
    	t.references :user, index: true, foreign_key: true, dependent: :delete
    	t.string :profile_image_url
    	t.integer :followers_count
    	t.integer :favourites_count
      t.timestamps null: false
    end
  end
end
