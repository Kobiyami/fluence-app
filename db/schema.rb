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

ActiveRecord::Schema[8.1].define(version: 2026_02_23_185628) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "reading_texts", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "word_count"
  end

  create_table "sessions", force: :cascade do |t|
    t.boolean "aborted", default: false, null: false
    t.datetime "created_at", null: false
    t.integer "duration_seconds"
    t.integer "score_wpm"
    t.bigint "student_id", null: false
    t.bigint "text_id", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_sessions_on_student_id"
    t.index ["text_id"], name: "index_sessions_on_text_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "sessions", "reading_texts", column: "text_id"
  add_foreign_key "sessions", "students"
end
