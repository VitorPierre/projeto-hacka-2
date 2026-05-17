class AddSenderIdToProposals < ActiveRecord::Migration[8.1]
  def up
    add_column :proposals, :sender_id, :integer

    # Backfill: assume existing proposals were sent by the student
    execute "UPDATE proposals SET sender_id = student_id WHERE sender_id IS NULL"

    change_column_null :proposals, :sender_id, false
    add_foreign_key :proposals, :users, column: :sender_id
  end

  def down
    remove_foreign_key :proposals, column: :sender_id
    remove_column :proposals, :sender_id
  end
end
