# frozen_string_literal: true

require_relative 'skill_installer'
require_relative 'skill_upgrade/review'

module RailsAIFoundry
  module Generation
    module SkillUpgrade
      class Command
        def initialize(root, target: 'agents')
          @assessment = Assessment.new(root, target)
          @store = @assessment.store
        end

        def call(apply: nil, resolve: nil, rollback: nil, pretend: false)
          raise InstallationError, 'Select only one upgrade action.' if [apply, resolve, rollback].compact.size > 1

          @store.lock do
            dispatch(apply, resolve, rollback, pretend)
          end
        rescue SystemCallError => e
          raise InstallationError, "Upgrade I/O failure (#{e.class}); inspect the session and repeat or roll back."
        rescue KeyError, TypeError, ArgumentError
          raise InstallationError, 'Malformed upgrade artifact; restore its reviewed original.'
        end

        def assert_idle!
          active = sessions.reject { |session| Session::TERMINAL.include?(session.state['phase']) }
          return if active.empty?

          raise InstallationError, "Upgrade pending: #{active.first.id}; resume apply or roll back before generation."
        end

        private

        def dispatch(apply, resolve, rollback, pretend)
          return resolve_document(resolve, pretend) if resolve
          return rollback_session(rollback, pretend) if rollback
          return apply_session(apply, pretend) if apply

          assert_idle!
          plan = @assessment.call
          describe(plan)
        end

        def describe(plan)
          rows = plan.fetch('files')
          counts = rows.map { |row| row['action'] }.tally.sort.map { |action, count| "#{action}=#{count}" }.join(' ')
          ["Review digest: #{Store.digest(plan)}", counts, *rows.map { |row| "#{row['action']} #{row['path']}" }]
        end

        def sessions
          base = ".foundry/skill-upgrades/#{@assessment.target}"
          @store.children(base).filter_map do |id|
            session = Session.new(@assessment, id)
            session.load if session.exists?
          end
        end

        def apply_session(id, pretend)
          session = Session.new(@assessment, id)
          if session.exists?
            session.load
            assert_selected!(session)
            return session.preview if pretend

            return session.apply
          end
          assert_idle!
          plan = @assessment.call
          raise InstallationError, 'Stale review digest; assess again.' unless id == Store.digest(plan)
          return ['Would apply reviewed safe updates.'] if pretend

          session.create(plan).apply
        end

        def resolve_document(path, pretend)
          document = @store.json(path)
          session = Session.new(@assessment, document.fetch('session')).load
          assert_selected!(session)
          Review.new(session, @store).resolve(document, pretend: pretend)
        end

        def rollback_session(id, pretend)
          session = Session.new(@assessment, id).load
          assert_selected!(session)
          Review.new(session, @store).rollback(pretend: pretend)
        end

        def assert_selected!(selected)
          other = sessions.find do |session|
            session.id != selected.id && !Session::TERMINAL.include?(session.state['phase'])
          end
          raise InstallationError, "Another upgrade is pending: #{other.id}" if other
        end
      end
    end
  end
end
