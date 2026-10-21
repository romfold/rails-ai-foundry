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

ActiveRecord::Schema[8.1].define(version: 2026_09_09_235000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "pipeline_cursors", force: :cascade do |t|
    t.integer "position", default: 0, null: false
    t.string "stream_key", null: false
    t.string "tenant", null: false
    t.bigint "total", default: 0, null: false
    t.index ["tenant", "stream_key"], name: "index_pipeline_cursors_on_tenant_and_stream_key", unique: true
  end

  create_table "pipeline_receipts", force: :cascade do |t|
    t.string "event_id", null: false
    t.string "fingerprint", null: false
    t.index ["event_id"], name: "index_pipeline_receipts_on_event_id", unique: true
  end

  create_table "pipeline_rejections", force: :cascade do |t|
    t.string "fingerprint", null: false
    t.text "payload", null: false
    t.string "reason", null: false
    t.index ["fingerprint"], name: "index_pipeline_rejections_on_fingerprint", unique: true
  end
end
