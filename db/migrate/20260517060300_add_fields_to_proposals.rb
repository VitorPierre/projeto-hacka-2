class AddFieldsToProposals < ActiveRecord::Migration[8.1]
  def change
    add_column :proposals, :recording_url, :string
    add_column :proposals, :rating, :integer
    add_column :proposals, :feedback, :text
  end
end
