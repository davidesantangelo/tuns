class AddAccessTokenAndAccessTokenSecretToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :access_token, :string, unique: true
    add_column :users, :access_token_secret, :string, unique: true
  end
end
