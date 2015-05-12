class AddAccessTokenAndAccessTokenSecretToUsers < ActiveRecord::Migration
  def change
    add_column :users, :access_token, :string, unique: true
    add_column :users, :access_token_secret, :string, unique: true
  end
end
