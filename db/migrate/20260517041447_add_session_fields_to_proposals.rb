class AddSessionFieldsToProposals < ActiveRecord::Migration[8.1]
  def change
    add_column :proposals, :paid, :boolean
    add_column :proposals, :scheduled_at, :datetime
    add_column :proposals, :started_at, :datetime
    add_column :proposals, :finished_at, :datetime
  end
end
