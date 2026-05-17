class AddModalityToProposals < ActiveRecord::Migration[8.1]
  def change
    add_column :proposals, :modality, :integer
    add_column :proposals, :duration, :integer
  end
end
