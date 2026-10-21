# frozen_string_literal: true

require 'bundler'
require 'open3'
require 'rbconfig'
require_relative 'audit_snapshot'
require_relative 'debt'
require_relative '../contracts'
require_relative '../support/command_text'

module RailsAIFoundry
  module Conventions
    class DebtAudit
      attr_reader :snapshot

      def initialize(root, pks: 'pks')
        @snapshot = AuditSnapshot.new(root)
        @pks = pks
      end

      def call(parity: false)
        preflight!
        snapshot.copy do |directory, inputs|
          captured = AuditSnapshot.new(directory)
          before = snapshot.fingerprint(inputs)
          report = captured_report(captured, before)
          compare_pks(report, captured) if parity
          finalize(report, before)
        end
      end

      def verify(evidence)
        unless valid_evidence?(evidence)
          raise ConfigurationError, 'Missing, unsupported, failed or stale application-specific pks parity evidence; ' \
                                    'rerun parity with the installed Foundry version.'
        end

        current = call(parity: true)
        raise ConfigurationError, 'Tool identity changed; rerun parity.' unless current['tools'] == evidence['tools']

        current
      end

      private

      def captured_report(captured, fingerprint)
        accepted = Debt.identities(captured.files.root)
        current, commands = regenerate(:packwerk, captured)
        debt_report(accepted, current).merge('application' => snapshot.files.root,
                                             'fingerprint' => fingerprint, 'commands' => commands)
      end

      def finalize(report, before)
        report['source_unchanged'] = before == snapshot.fingerprint
        report['success'] = successful?(report)
        Contracts.report(report.key?('parity') ? 'parity' : 'audit', report)
      end

      def debt_report(accepted, current)
        { 'accepted' => accepted, 'current' => current, 'new' => current - accepted,
          'resolved' => accepted - current, 'retained' => accepted & current, 'authority' => 'packwerk',
          'limitations' => 'Disposable filesystem copies; application boot is not network-isolated. ' \
                           'Caches, secrets and runtime data are excluded; review custom analysis inputs.' }
      end

      def successful?(report)
        report['source_unchanged'] && report['new'].empty? && report.fetch('parity', true)
      end

      def valid_evidence?(evidence)
        evidence.is_a?(Hash) &&
          evidence.values_at('report_schema', 'report_kind', 'foundry_version').eql?([1, 'parity', VERSION]) &&
          evidence.values_at('success', 'parity') == [true, true] &&
          evidence['application'] == snapshot.files.root && evidence['fingerprint'] == snapshot.fingerprint
      end

      def preflight!
        snapshot.files.application!
        return if snapshot.files.exist?('Gemfile.lock') && snapshot.files.exist?('packwerk.yml')

        raise ConfigurationError, 'Audit requires packwerk.yml and an installed locked application bundle.'
      end

      def compare_pks(report, captured)
        identities, commands = regenerate(:pks, captured)
        report['commands'].concat(commands)
        report['pks_only'] = identities - report['current']
        report['packwerk_only'] = report['current'] - identities
        report['parity'] = identities == report['current']
        report['tools'] = tool_versions
      end

      def tool_versions
        { 'packwerk' => execute(:packwerk, '--version', snapshot.files.root)['stdout'].strip,
          'pks' => execute(:pks, '--version', snapshot.files.root)['stdout'].strip,
          'ruby' => RUBY_DESCRIPTION, 'pks_sha256' => Digest::SHA256.file(pks_path).hexdigest }
      end

      def pks_path
        return File.expand_path(@pks) if @pks.include?(File::SEPARATOR)

        path = ENV.fetch('PATH', '').split(File::PATH_SEPARATOR).map { |directory| File.join(directory, @pks) }
                  .find { |candidate| File.file?(candidate) && File.executable?(candidate) }
        path || raise(ConfigurationError, 'Install pks and supply --pks=PATH.')
      end

      def regenerate(backend, captured)
        commands = []
        identities = captured.copy do |directory|
          AuditSnapshot.new(directory).paths.grep(%r{(?:\A|/)package_todo\.yml\z}).each do |path|
            File.unlink(File.join(directory, path))
          end
          commands << execute(backend, 'validate', directory)
          commands << execute(backend, backend == :packwerk ? 'update-todo' : 'update', directory)
          Debt.identities(directory)
        end
        [identities, commands]
      end

      def command(backend, action)
        return [pks_path, '--no-cache', action] if backend == :pks

        prefix = [RbConfig.ruby, '-S', 'bundle', 'exec', RbConfig.ruby]
        return [*prefix, '-e', "puts Gem.loaded_specs.fetch('packwerk').version"] if action == '--version'

        [*prefix, '-rstringio', '-S', 'packwerk', action]
      end

      def execute(backend, action, directory)
        argv = command(backend, action)
        environment = { 'BUNDLE_GEMFILE' => snapshot.files.path('Gemfile'), 'BUNDLE_FROZEN' => 'true',
                        'BUNDLE_VERSION' => Bundler::VERSION, 'RAILS_ENV' => 'test', 'RACK_ENV' => 'test' }
        output, error, status = Bundler.with_unbundled_env do
          Open3.capture3(environment, *argv, chdir: directory)
        end
        output = Support::CommandText.normalize(output)
        error = Support::CommandText.normalize(error)
        unless status.success?
          raise ConfigurationError, "#{backend} #{action} failed (#{status.exitstatus}):\n#{output}\n#{error}"
        end

        { 'argv' => argv, 'stdout' => output, 'stderr' => error, 'exit_status' => status.exitstatus }
      end
    end
  end
end
