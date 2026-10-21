# frozen_string_literal: true

require_relative 'session'

module RailsAIFoundry
  module Generation
    module SkillUpgrade
      class Review
        def initialize(session, store)
          @session = session
          @store = store
        end

        def resolve(document, pretend: false)
          unless @session.state['phase'] == 'pending'
            raise InstallationError, 'Resolution requires pending review; resume the apply action first.'
          end

          entries = decisions(document)
          ops = entries.map { |row, choice| resolution(row, choice) }
          verify_other_files(ops)
          return ['Would record decisions and complete upgrade.'] if pretend

          publish_decisions(document, ops)
          @session.apply
        end

        def rollback(pretend: false)
          return ['Session already rolled back.'] if @session.state['phase'] == 'rolled_back'

          ops = rollback_operations
          verify_rollback(ops)
          return ['Would restore recorded original files and receipt.'] if pretend

          @session.state['phase'] = 'rolling_back'
          @session.save
          ops.each { |op| @store.replace(op['path'], op.fetch('observed'), op['before']) }
          @session.state['phase'] = 'rolled_back'
          @session.save
          ['Upgrade rolled back; original files and receipt restored.']
        end

        private

        def publish_decisions(document, ops)
          @session.state['operations'].concat(ops)
          @session.state['decisions'] = document.fetch('files')
          @session.state['phase'] = 'resolving'
          @session.save
        end

        def verify_rollback(ops)
          ops.each do |op|
            op['observed'] = @store.snapshot(op['path'])
            next if [op['before'], op['after'], op['intermediate']].include?(op['observed'])

            raise InstallationError, "Later edit blocks rollback: #{op['path']}"
          end
        end

        def document_shape?(document)
          document.is_a?(Hash) && document.keys.sort == %w[files session] &&
            document['session'] == @session.id && document['files'].is_a?(Hash)
        end

        def choice_shape?(choice)
          choice.is_a?(Hash) && choice.keys.sort == %w[decision sha256] &&
            %w[keep_local use_upstream merged].include?(choice['decision'])
        end

        def decisions(document)
          expected = @session.pending.map { |row| row.fetch('path') }.sort
          valid = document_shape?(document) && document['files'].keys.sort == expected
          unless valid
            raise InstallationError,
                  'Decisions must identify this session and every pending file exactly once.'
          end

          @session.pending.map { |row| [row, document['files'].fetch(row.fetch('path'))] }
        end

        def resolution(row, choice)
          current = @store.snapshot(row.fetch('path'))
          valid = choice_shape?(choice) && current && choice['sha256'] == current['sha256']
          raise InstallationError, "Invalid or stale decision: #{row['path']}" unless valid

          validate_retirement(row, choice)

          after = choice['decision'] == 'use_upstream' ? row['upstream'] : current
          row.slice('path').merge('before' => current, 'after' => after)
        end

        def validate_retirement(row, choice)
          return unless choice['decision'] == 'merged' && !row['upstream']

          raise InstallationError, "Retired file requires keep_local or use_upstream: #{row['path']}"
        end

        def verify_other_files(ops)
          saved = @session.operations.dup
          @session.state['operations'].concat(ops)
          @session.verify_states
        ensure
          @session.state['operations'] = saved
        end

        def rollback_operations
          originals = @session.plan.fetch('files').to_h { |row| [row['path'], row['before']] }
          ops = @session.operations.map do |op|
            op.merge('before' => originals.fetch(op['path']), 'intermediate' => op['before'])
          end
          [receipt_operation, *ops.reverse]
        end

        def receipt_operation
          plan = @session.plan
          { 'path' => plan.fetch('receipt_path'), 'before' => plan.fetch('receipt_before'),
            'after' => plan.fetch('receipt_after'), 'intermediate' => plan.fetch('receipt_before') }
        end
      end
    end
  end
end
