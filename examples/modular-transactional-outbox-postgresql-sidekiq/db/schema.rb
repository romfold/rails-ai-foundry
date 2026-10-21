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

ActiveRecord::Schema[8.1].define(version: 2026_09_09_233000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "orders_orders", force: :cascade do |t|
    t.integer "cents", null: false
    t.string "state", default: "placed", null: false
    t.string "tenant", null: false
    t.check_constraint "cents > 0", name: "positive_order"
  end

  create_table "orders_outbox_entries", force: :cascade do |t|
    t.integer "attempts", default: 0, null: false
    t.datetime "completed_at"
    t.string "last_error"
    t.datetime "next_attempt_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.jsonb "payload", null: false
    t.datetime "poisoned_at"
    t.index ["next_attempt_at"], name: "index_orders_outbox_entries_on_next_attempt_at", where: "((completed_at IS NULL) AND (poisoned_at IS NULL))"
  end

  create_table "orders_receipts", force: :cascade do |t|
    t.bigint "outbox_entry_id", null: false
    t.index ["outbox_entry_id"], name: "index_orders_receipts_on_outbox_entry_id", unique: true
  end

  add_foreign_key "orders_receipts", "orders_outbox_entries", column: "outbox_entry_id"
end
