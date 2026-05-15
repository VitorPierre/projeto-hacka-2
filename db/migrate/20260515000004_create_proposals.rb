class CreateProposals < ActiveRecord::Migration[7.0]
  def change
    create_table :proposals do |t|
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :teacher, null: false, foreign_key: { to_table: :users }
      t.references :subject, null: false, foreign_key: true
      t.decimal :price, precision: 10, scale: 2
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
