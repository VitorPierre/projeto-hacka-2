class CreateAuditLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :audit_logs do |t|
      t.references :admin, foreign_key: { to_table: :users }
      t.string :admin_email
      t.string :action
      t.references :target, foreign_key: { to_table: :users }
      t.string :target_name
      t.text :details

      t.timestamps
    end
  end
end
