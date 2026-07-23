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

ActiveRecord::Schema[8.1].define(version: 2026_07_23_091449) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "mot_outils", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "text"
    t.datetime "updated_at", null: false
  end

  create_table "reading_texts", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "word_count"
  end

  create_table "sessions", force: :cascade do |t|
    t.boolean "aborted", default: false, null: false
    t.integer "completion_rate"
    t.datetime "created_at", null: false
    t.integer "duration_seconds"
    t.integer "mclm_score"
    t.bigint "reading_text_id", null: false
    t.string "status"
    t.bigint "student_id", null: false
    t.text "transcription"
    t.datetime "updated_at", null: false
    t.jsonb "word_alignment"
    t.integer "word_count_correct"
    t.integer "word_count_errors"
    t.integer "word_count_omissions"
    t.index ["reading_text_id"], name: "index_sessions_on_reading_text_id"
    t.index ["student_id"], name: "index_sessions_on_student_id"
  end

  create_table "student_word_timings", force: :cascade do |t|
    t.integer "allowed_time"
    t.datetime "created_at", null: false
    t.datetime "last_seen_at"
    t.bigint "mot_outil_id", null: false
    t.bigint "student_id", null: false
    t.datetime "updated_at", null: false
    t.index ["mot_outil_id"], name: "index_student_word_timings_on_mot_outil_id"
    t.index ["student_id"], name: "index_student_word_timings_on_student_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "sessions", "reading_texts"
  add_foreign_key "sessions", "students"
  add_foreign_key "student_word_timings", "mot_outils"
  add_foreign_key "student_word_timings", "students"
end
