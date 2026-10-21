# frozen_string_literal: true

class CreateReviewedResolutions < ActiveRecord::Migration[8.1]
  # Declarative migration DDL is kept together for review.
  # rubocop:disable-next Metrics/AbcSize, Metrics/MethodLength
  def change
    add_column :assistance_tickets, :lock_version, :integer, default: 0, null: false
    add_column :assistance_tickets, :approved_resolution, :text
    create_table :resolution_requests do |t|
      t.references :ticket, null: false, foreign_key: { to_table: :assistance_tickets }
      t.references :requester, null: false, foreign_key: { to_table: :assistance_users }
      t.references :approver, foreign_key: { to_table: :assistance_users }
      t.references :previous_request, foreign_key: { to_table: :resolution_requests }
      t.string :tenant, null: false
      t.string :idempotency_key, null: false
      t.string :input_digest, null: false
      t.text :question, null: false
      t.jsonb :snapshot, null: false
      t.integer :source_revision, null: false
      t.string :state, default: 'queued', null: false
      t.text :proposal
      t.string :proposal_digest
      t.string :lease_token
      t.datetime :lease_expires_at
      t.datetime :next_attempt_at, null: false
      t.integer :attempt_count, default: 0, null: false
      t.string :failure_code
      t.datetime :approved_at
      t.datetime :completed_at
      t.timestamps
    end
    add_index :resolution_requests, %i[requester_id idempotency_key], unique: true
    add_index :resolution_requests, :ticket_id, unique: true, name: 'one_active_resolution_per_ticket',
                                                where: "state IN ('queued','generating','awaiting_review','approved')"
    add_check_constraint :resolution_requests,
                         "state IN ('queued','generating','awaiting_review','approved','completed','rejected'," \
                         "'cancelled','failed','stale')", name: 'resolution_state'
    add_check_constraint :resolution_requests, 'char_length(question) BETWEEN 1 AND 2000', name: 'question_bound'
    add_check_constraint :resolution_requests, 'char_length(proposal) BETWEEN 1 AND 2000', name: 'proposal_bound'
    add_check_constraint :resolution_requests, 'attempt_count BETWEEN 0 AND 3', name: 'attempt_bound'
    create_table :generation_attempts do |t|
      t.references :resolution_request, null: false, foreign_key: true
      t.string :token, null: false
      t.integer :number, null: false
      t.string :provider, null: false
      t.string :state, null: false
      t.string :failure_code
      t.datetime :finished_at
      t.timestamps
    end
    add_index :generation_attempts, :token, unique: true
    add_index :generation_attempts, %i[resolution_request_id number], unique: true
    create_table :resolution_audits do |t|
      t.references :resolution_request, null: false, foreign_key: true
      t.references :actor, foreign_key: { to_table: :assistance_users }
      t.string :event, null: false
      t.jsonb :details, default: {}, null: false
      t.datetime :created_at, null: false
    end
    add_index :resolution_audits, :resolution_request_id, unique: true,
                                                          where: "event = 'completed'",
                                                          name: 'one_resolution_completion'
  end
end
