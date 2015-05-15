class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :followers do |t|
    	t.references :user, index: true, foreign_key: true, dependent: :delete
    	t.string :uid
      t.timestamps null: false
    end
    add_index :followers, [:user_id, :uid], unique: true
  end
end
