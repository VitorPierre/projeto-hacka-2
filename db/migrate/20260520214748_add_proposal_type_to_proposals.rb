class AddProposalTypeToProposals < ActiveRecord::Migration[8.1]
  def change
    add_column :proposals, :proposal_type, :integer, default: 0, null: false
  end
end
