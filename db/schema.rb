# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_15_123456) do
  create_table "messages", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "proposal_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["proposal_id"], name: "index_messages_on_proposal_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "proposals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "price", precision: 10, scale: 2
    t.integer "status", default: 0
    t.integer "student_id", null: false
    t.integer "subject_id", null: false
    t.integer "teacher_id", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_proposals_on_student_id"
    t.index ["subject_id"], name: "index_proposals_on_subject_id"
    t.index ["teacher_id"], name: "index_proposals_on_teacher_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "subjects_users", id: false, force: :cascade do |t|
    t.integer "subject_id", null: false
    t.integer "user_id", null: false
    t.index ["subject_id", "user_id"], name: "index_subjects_users_on_subject_id_and_user_id"
    t.index ["user_id", "subject_id"], name: "index_subjects_users_on_user_id_and_subject_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "certificate_url"
    t.boolean "certified", default: false
    t.datetime "created_at", null: false
    t.integer "education_level", default: 0
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.integer "role", default: 0
    t.datetime "updated_at", null: false
  end

  add_foreign_key "messages", "proposals"
  add_foreign_key "messages", "users"
  add_foreign_key "proposals", "subjects"
  add_foreign_key "proposals", "users", column: "student_id"
  add_foreign_key "proposals", "users", column: "teacher_id"
end
