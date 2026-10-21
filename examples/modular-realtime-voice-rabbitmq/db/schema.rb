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

ActiveRecord::Schema[8.1].define(version: 2026_09_09_030000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "voice_controls", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "available_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "delivered_at"
    t.string "event_id", null: false
    t.jsonb "payload", null: false
    t.datetime "poisoned_at"
    t.index ["event_id"], name: "index_voice_controls_on_event_id", unique: true
  end

  create_table "voice_frames", force: :cascade do |t|
    t.binary "data", null: false
    t.integer "epoch", null: false
    t.integer "sequence", null: false
    t.bigint "session_id", null: false
    t.index ["session_id", "epoch", "sequence"], name: "index_voice_frames_on_session_id_and_epoch_and_sequence", unique: true
    t.index ["session_id"], name: "index_voice_frames_on_session_id"
    t.check_constraint "octet_length(data) <= 4096", name: "bounded_voice_frame"
  end

  create_table "voice_receipts", force: :cascade do |t|
    t.string "event_id", null: false
    t.string "fingerprint", null: false
    t.index ["event_id"], name: "index_voice_receipts_on_event_id", unique: true
  end

  create_table "voice_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "delivered_epoch", default: 0, null: false
    t.integer "epoch", default: 0, null: false
    t.integer "last_sequence", default: -1, null: false
    t.string "state", default: "idle", null: false
    t.string "tenant_id", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "voice_frames", "voice_sessions", column: "session_id", on_delete: :cascade
end
