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

ActiveRecord::Schema[8.0].define(version: 2025_09_16_005252) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "mentorship_requests", force: :cascade do |t|
    t.bigint "mentee_id", null: false
    t.bigint "mentor_id"
    t.string "topic"
    t.text "goals"
    t.string "preferred_times"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mentee_id"], name: "index_mentorship_requests_on_mentee_id"
    t.index ["mentor_id"], name: "index_mentorship_requests_on_mentor_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "mentorship_request_id", null: false
    t.bigint "user_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mentorship_request_id"], name: "index_messages_on_mentorship_request_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.text "bio"
    t.integer "years_experience"
    t.string "timezone"
    t.string "skills"
    t.text "availability"
    t.string "github_url"
    t.string "x_url"
    t.string "website_url"
    t.boolean "mentor", default: false, null: false
    t.boolean "mentee", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "mentorship_requests", "users", column: "mentee_id"
  add_foreign_key "mentorship_requests", "users", column: "mentor_id"
  add_foreign_key "messages", "mentorship_requests"
  add_foreign_key "messages", "users"
  add_foreign_key "profiles", "users"
end
