class AddSystemToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :system, :boolean, default: false
  end
end
