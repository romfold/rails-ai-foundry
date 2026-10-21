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

ActiveRecord::Schema[8.1].define(version: 2026_09_09_234000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "knowledge_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "body", null: false
    t.boolean "deleted", default: false, null: false
    t.jsonb "embedding", null: false
    t.string "embedding_version", null: false
    t.integer "revision", default: 1, null: false
    t.string "tenant", null: false
    t.string "title", null: false
    t.index ["tenant", "embedding_version"], name: "index_knowledge_documents_on_tenant_and_embedding_version"
  end

  create_table "knowledge_gates", force: :cascade do |t|
    t.string "name", null: false
    t.index ["name"], name: "index_knowledge_gates_on_name", unique: true
  end
end
