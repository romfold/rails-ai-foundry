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

ActiveRecord::Schema[8.1].define(version: 2026_09_22_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "assistance_tickets", force: :cascade do |t|
    t.text "approved_resolution"
    t.integer "lock_version", default: 0, null: false
    t.string "status", default: "open", null: false
    t.string "subject", null: false
    t.string "tenant", null: false
    t.index ["tenant"], name: "index_assistance_tickets_on_tenant"
    t.check_constraint "status::text = ANY (ARRAY['open'::character varying::text, 'closed'::character varying::text])", name: "ticket_status"
  end

  create_table "assistance_users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.boolean "can_close", default: false, null: false
    t.string "tenant", null: false
    t.string "token", null: false
    t.index ["token"], name: "index_assistance_users_on_token", unique: true
  end

  create_table "generation_attempts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "failure_code"
    t.datetime "finished_at"
    t.integer "number", null: false
    t.string "provider", null: false
    t.bigint "resolution_request_id", null: false
    t.string "state", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["resolution_request_id", "number"], name: "index_generation_attempts_on_resolution_request_id_and_number", unique: true
    t.index ["resolution_request_id"], name: "index_generation_attempts_on_resolution_request_id"
    t.index ["token"], name: "index_generation_attempts_on_token", unique: true
  end

  create_table "resolution_audits", force: :cascade do |t|
    t.bigint "actor_id"
    t.datetime "created_at", null: false
    t.jsonb "details", default: {}, null: false
    t.string "event", null: false
    t.bigint "resolution_request_id", null: false
    t.index ["actor_id"], name: "index_resolution_audits_on_actor_id"
    t.index ["resolution_request_id"], name: "index_resolution_audits_on_resolution_request_id"
    t.index ["resolution_request_id"], name: "one_resolution_completion", unique: true, where: "((event)::text = 'completed'::text)"
  end

  create_table "resolution_requests", force: :cascade do |t|
    t.datetime "approved_at"
    t.bigint "approver_id"
    t.integer "attempt_count", default: 0, null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "failure_code"
    t.string "idempotency_key", null: false
    t.string "input_digest", null: false
    t.datetime "lease_expires_at"
    t.string "lease_token"
    t.datetime "next_attempt_at", null: false
    t.bigint "previous_request_id"
    t.text "proposal"
    t.string "proposal_digest"
    t.text "question", null: false
    t.bigint "requester_id", null: false
    t.jsonb "snapshot", null: false
    t.integer "source_revision", null: false
    t.string "state", default: "queued", null: false
    t.string "tenant", null: false
    t.bigint "ticket_id", null: false
    t.datetime "updated_at", null: false
    t.index ["approver_id"], name: "index_resolution_requests_on_approver_id"
    t.index ["previous_request_id"], name: "index_resolution_requests_on_previous_request_id"
    t.index ["requester_id", "idempotency_key"], name: "index_resolution_requests_on_requester_id_and_idempotency_key", unique: true
    t.index ["requester_id"], name: "index_resolution_requests_on_requester_id"
    t.index ["ticket_id"], name: "index_resolution_requests_on_ticket_id"
    t.index ["ticket_id"], name: "one_active_resolution_per_ticket", unique: true, where: "((state)::text = ANY ((ARRAY['queued'::character varying, 'generating'::character varying, 'awaiting_review'::character varying, 'approved'::character varying])::text[]))"
    t.check_constraint "attempt_count >= 0 AND attempt_count <= 3", name: "attempt_bound"
    t.check_constraint "char_length(proposal) >= 1 AND char_length(proposal) <= 2000", name: "proposal_bound"
    t.check_constraint "char_length(question) >= 1 AND char_length(question) <= 2000", name: "question_bound"
    t.check_constraint "state::text = ANY (ARRAY['queued'::character varying, 'generating'::character varying, 'awaiting_review'::character varying, 'approved'::character varying, 'completed'::character varying, 'rejected'::character varying, 'cancelled'::character varying, 'failed'::character varying, 'stale'::character varying]::text[])", name: "resolution_state"
  end

  create_table "solid_queue_batch_executions", force: :cascade do |t|
    t.bigint "batch_id", null: false
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.index ["batch_id"], name: "index_solid_queue_batch_executions_on_batch_id"
    t.index ["job_id"], name: "index_solid_queue_batch_executions_on_job_id", unique: true
  end

  create_table "solid_queue_batches", force: :cascade do |t|
    t.string "active_job_batch_id"
    t.integer "completed_jobs", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.datetime "enqueued_at"
    t.datetime "failed_at"
    t.integer "failed_jobs", default: 0, null: false
    t.datetime "finished_at"
    t.text "metadata"
    t.text "on_failure"
    t.text "on_finish"
    t.text "on_success"
    t.integer "total_jobs", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_batch_id"], name: "index_solid_queue_batches_on_active_job_batch_id", unique: true
    t.index ["finished_at"], name: "index_solid_queue_batches_on_finished_at"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.bigint "batch_id"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["batch_id"], name: "index_solid_queue_jobs_on_batch_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  add_foreign_key "generation_attempts", "resolution_requests"
  add_foreign_key "resolution_audits", "assistance_users", column: "actor_id"
  add_foreign_key "resolution_audits", "resolution_requests"
  add_foreign_key "resolution_requests", "assistance_tickets", column: "ticket_id"
  add_foreign_key "resolution_requests", "assistance_users", column: "approver_id"
  add_foreign_key "resolution_requests", "assistance_users", column: "requester_id"
  add_foreign_key "resolution_requests", "resolution_requests", column: "previous_request_id"
  add_foreign_key "solid_queue_batch_executions", "solid_queue_batches", column: "batch_id", on_delete: :cascade
  add_foreign_key "solid_queue_batch_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
end
