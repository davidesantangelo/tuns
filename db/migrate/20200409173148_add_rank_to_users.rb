class AddRankToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :rank, :float, default: 1.0
  end
end
