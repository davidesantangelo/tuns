class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :followers do |t|
    	t.references :user, index: true, foreign_key: true, dependent: :delete
    	t.string :username
      t.timestamps null: false
    end
    add_index :followers, [:user_id, :username], unique: true
  end
end
