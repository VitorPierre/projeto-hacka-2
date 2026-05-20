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

ActiveRecord::Schema[8.1].define(version: 2026_05_20_214748) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audit_logs", force: :cascade do |t|
    t.string "action"
    t.string "admin_email"
    t.integer "admin_id"
    t.datetime "created_at", null: false
    t.text "details"
    t.integer "target_id"
    t.string "target_name"
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_audit_logs_on_admin_id"
    t.index ["target_id"], name: "index_audit_logs_on_target_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.integer "message_type", default: 0, null: false
    t.text "options"
    t.integer "proposal_id", null: false
    t.integer "question_type", default: 0, null: false
    t.text "student_answer"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["proposal_id"], name: "index_messages_on_proposal_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "message"
    t.datetime "read_at"
    t.datetime "updated_at", null: false
    t.string "url"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "proposals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "duration"
    t.text "feedback"
    t.datetime "finished_at"
    t.integer "modality"
    t.boolean "paid"
    t.decimal "price", precision: 10, scale: 2
    t.integer "proposal_type", default: 0, null: false
    t.integer "rating"
    t.string "recording_url"
    t.datetime "scheduled_at"
    t.integer "sender_id", null: false
    t.datetime "started_at"
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
    t.boolean "admin", default: false
    t.text "availability"
    t.string "certificate_url"
    t.boolean "certified", default: false
    t.string "cpf"
    t.datetime "created_at", null: false
    t.integer "education_level", default: 0
    t.string "email"
    t.text "experience"
    t.integer "moderation_status", default: 0
    t.string "name"
    t.string "password_digest"
    t.boolean "pcd", default: false, null: false
    t.string "phone"
    t.text "preferences"
    t.string "presentation_video_url"
    t.string "privacy_accepted_version"
    t.integer "role", default: 0
    t.integer "status", default: 0
    t.datetime "terms_accepted_at"
    t.string "terms_accepted_version"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "audit_logs", "users", column: "admin_id"
  add_foreign_key "audit_logs", "users", column: "target_id"
  add_foreign_key "messages", "proposals"
  add_foreign_key "messages", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "proposals", "subjects"
  add_foreign_key "proposals", "users", column: "sender_id"
  add_foreign_key "proposals", "users", column: "student_id"
  add_foreign_key "proposals", "users", column: "teacher_id"
end
