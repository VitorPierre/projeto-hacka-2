class AddPcdToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :pcd, :boolean, default: false, null: false
  end
end
