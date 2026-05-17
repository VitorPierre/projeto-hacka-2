class AddStatusAndModerationStatusToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :status, :integer, default: 0 # 0: active, 1: suspended, 2: banned
    add_column :users, :moderation_status, :integer, default: 0 # 0: unreviewed, 1: flagged_suspicious, 2: reviewed_safe
  end
end
