class AddMetadataToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :metadata, :jsonb, null: false, default: '{}'
    add_index  :users, :metadata, using: :gin
  end
end
