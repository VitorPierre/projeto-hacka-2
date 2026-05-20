class AddTermsAndPrivacyAcceptanceToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :terms_accepted_version, :string
    add_column :users, :privacy_accepted_version, :string
    add_column :users, :terms_accepted_at, :datetime
  end
end
