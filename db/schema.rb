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

ActiveRecord::Schema[7.0].define(version: 2025_05_03_045617) do
  create_table "activity_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "health_log_id", null: false
    t.string "activity_type"
    t.integer "duration_minutes"
    t.string "intensity"
    t.json "custom_fields"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["health_log_id"], name: "index_activity_logs_on_health_log_id"
  end

  create_table "custom_field_definitions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "field_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_custom_field_definitions_on_user_id"
  end

  create_table "custom_fields", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "field_type", null: false
    t.string "category", null: false
    t.json "options"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "category", "name"], name: "index_custom_fields_on_user_id_and_category_and_name", unique: true
  end

  create_table "exercise_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "health_record_id"
    t.string "activity_type"
    t.integer "duration"
    t.float "distance"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "health_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "logged_on", null: false
    t.integer "mood"
    t.integer "stress_level"
    t.integer "fatigue_level"
    t.text "notes"
    t.json "custom_fields"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "logged_on"], name: "index_health_logs_on_user_id_and_logged_on"
  end

  create_table "health_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "date"
    t.integer "mood"
    t.integer "stress"
    t.integer "fatigue"
    t.integer "sleep_duration"
    t.integer "sleep_quality"
    t.text "memo"
    t.json "custom_fields"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "profile_id"
    t.index ["profile_id"], name: "index_health_records_on_profile_id"
  end

  create_table "pressure_readings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "recorded_at"
    t.float "pressure"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_now"
  end

  create_table "profiles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "age"
    t.decimal "height_cm", precision: 5, scale: 2
    t.decimal "weight_kg", precision: 5, scale: 2
    t.json "custom_fields"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
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

  add_foreign_key "activity_logs", "health_logs"
  add_foreign_key "custom_fields", "users"
  add_foreign_key "health_logs", "users"
  add_foreign_key "profiles", "users"
end
