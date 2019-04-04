class RemoveExtras < ActiveRecord::Migration[5.2]
  def change
    drop_table :extras
  end
end
