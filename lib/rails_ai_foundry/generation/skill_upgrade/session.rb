# frozen_string_literal: true

require_relative 'assessment'

module RailsAIFoundry
  module Generation
    module SkillUpgrade
      class Session
        TERMINAL = %w[complete rolled_back].freeze
        attr_reader :plan, :id, :directory, :state

        def initialize(assessment, id)
          raise InstallationError, 'Invalid review/session digest.' unless Assessment::HASH.match?(id.to_s)

          @assessment = assessment
          @store = assessment.store
          @id = id
          @directory = ".foundry/skill-upgrades/#{assessment.target}/#{id}"
        end

        def exists?
          !@store.snapshot("#{directory}/plan.json").nil?
        end

        def load
          @plan = @store.json("#{directory}/plan.json")
          validate_plan
          @state = if @store.snapshot(state_path)
                     @store.json(state_path)
                   else
                     initial_state
                   end
          validate_state
          self
        end

        def create(plan)
          raise InstallationError, 'Stale review digest; assess again.' unless Store.digest(plan) == id

          @plan = plan
          @store.private_directory('.foundry/skill-upgrades')
          protect_backups
          @store.private_directory(File.dirname(directory))
          @store.private_directory(directory)
          @store.write_json("#{directory}/plan.json", plan)
          @state = initial_state
          save
          self
        end

        def preview
          check_phase
          verify_states unless state['phase'] == 'complete'
          ['Would resume recorded upgrade; no files changed.']
        end

        def apply
          check_phase
          return ['Upgrade complete; recorded customizations preserved.'] if state['phase'] == 'complete'

          verify_states
          prepare_review
          execute_operations
          return finish if state['phase'] == 'resolving' || pending.empty?

          @state['phase'] = 'pending'
          save
          write_decisions
          raise InstallationError, "Safe updates applied; review pending. Resolve #{directory}/decisions.json."
        end

        def pending
          plan.fetch('files').select { |row| row['action'] == 'review' }
        end

        def operations
          state.fetch('operations')
        end

        def save
          @store.write_json(state_path, state)
        end

        def verify_states
          expected_states.each do |path, possibilities|
            next if possibilities.include?(@store.snapshot(path))

            raise InstallationError, "Changed file blocks recovery: #{path}"
          end
        end

        def execute_operations
          operations.each { |op| @store.replace(op.fetch('path'), op['before'], op['after']) }
        end

        def finish
          @store.replace(plan.fetch('receipt_path'), plan.fetch('receipt_before'), plan.fetch('receipt_after'))
          state['phase'] = 'complete'
          state['accepted'] = accepted_files
          save
          ["Upgrade complete: #{id}; customizations recorded separately from template provenance."]
        end

        private

        def protect_backups
          path = '.foundry/skill-upgrades/.gitignore'
          @store.replace(path, nil, Store.content("*\n!.gitignore\n", 0o600)) unless @store.snapshot(path)
        end

        def check_phase
          case state['phase']
          when 'rolled_back' then raise InstallationError, 'Session was rolled back; assess current files again.'
          when 'rolling_back' then raise InstallationError, 'Rollback interrupted; repeat rollback.'
          end
        end

        def validate_plan
          valid = plan_shape? && Store.digest(plan) == id
          raise InstallationError, 'Upgrade plan integrity check failed.' unless valid

          plan.fetch('files').each { |row| @assessment.validate_path(row.fetch('path'), inspect: false) }
        end

        def plan_shape?
          plan.is_a?(Hash) && plan['target'] == @assessment.target && plan['schema'] == 1 &&
            plan['receipt_path'] == @assessment.receipt_path && plan['files'].is_a?(Array)
        end

        def accepted_files
          plan.fetch('files').to_h do |row|
            [row.fetch('path'), @store.snapshot(row.fetch('path'))&.slice('sha256', 'mode')]
          end
        end

        def expected_states
          expected = plan.fetch('files').to_h { |row| [row.fetch('path'), [row['before']]] }
          expected[plan.fetch('receipt_path')] = receipt_states
          operations.each { |op| expected.fetch(op['path']).push(op['before'], op['after']) }
          expected
        end

        def receipt_states
          values = [plan.fetch('receipt_before')]
          values << plan.fetch('receipt_after') if state['phase'] == 'resolving' || pending.empty?
          values
        end

        def prepare_review
          pending.each do |row|
            { 'local' => row['before'], 'upstream' => row['upstream'] }.each do |kind, data|
              next unless data

              path = "#{directory}/#{kind}/#{row['path']}"
              @store.replace(path, nil, data.merge('mode' => 0o600))
            end
          end
        end

        def initial_state
          ops = plan.fetch('files').select { |row| %w[add update remove].include?(row['action']) }.map do |row|
            row.slice('path', 'before').merge('after' => row['upstream'])
          end
          { 'phase' => 'applying', 'operations' => ops, 'decisions' => {} }
        end

        def state_path
          "#{directory}/state.json"
        end

        def validate_state
          valid = state.is_a?(Hash) &&
                  %w[applying pending resolving complete rolling_back rolled_back].include?(state['phase']) &&
                  valid_operations?
          raise InstallationError, 'Invalid upgrade progress journal.' unless valid
        end

        def valid_operations?
          allowed = plan.fetch('files').map { |row| row['path'] }
          operations.is_a?(Array) && operations.all? { |op| op.is_a?(Hash) && allowed.include?(op['path']) }
        end

        def write_decisions
          path = "#{directory}/decisions.json"
          return if @store.snapshot(path)

          files = pending.to_h do |row|
            [row.fetch('path'), { 'decision' => 'REVIEW_REQUIRED', 'sha256' => row.fetch('before').fetch('sha256') }]
          end
          @store.write_json(path, { 'session' => id, 'files' => files })
        end
      end
    end
  end
end
