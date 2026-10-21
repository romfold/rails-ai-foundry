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

ActiveRecord::Schema[8.1].define(version: 2026_09_09_000000) do
  create_table "billing_invoices", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.datetime "created_at", null: false
    t.string "reference", null: false
    t.string "status", default: "open", null: false
    t.datetime "updated_at", null: false
    t.index ["reference"], name: "index_billing_invoices_on_reference", unique: true
    t.check_constraint "amount_cents >= 0", name: "nonnegative_invoice_amount"
    t.check_constraint "status IN ('open', 'paid')", name: "valid_invoice_status"
  end
end
