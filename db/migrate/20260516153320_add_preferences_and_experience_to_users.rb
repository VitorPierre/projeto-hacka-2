class AddPreferencesAndExperienceToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :preferences, :text
    add_column :users, :experience, :text
  end
end
