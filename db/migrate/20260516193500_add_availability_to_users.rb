class AddAvailabilityToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :availability, :text
  end
end
