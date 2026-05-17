class AddActivityFieldsToMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :messages, :message_type, :integer, default: 0, null: false
    add_column :messages, :question_type, :integer, default: 0, null: false
    add_column :messages, :options, :text
    add_column :messages, :student_answer, :text
  end
end
