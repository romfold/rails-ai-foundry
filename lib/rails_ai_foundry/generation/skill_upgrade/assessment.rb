# frozen_string_literal: true

require_relative 'store'

module RailsAIFoundry
  module Generation
    module SkillUpgrade
      class Assessment
        HASH = /\A[0-9a-f]{64}\z/
        attr_reader :store, :target, :receipt_path, :destination

        def initialize(root, target)
          @store = Store.new(root)
          @target = target
          @destination = SkillInstaller::TARGETS.fetch(target) do
            raise InstallationError, 'Use target agents, claude or cursor.'
          end
          @receipt_path = ".foundry/skills/#{target}.json"
          @incoming = SkillInstaller.new(root, target: target).files
        end

        def call
          receipt = store.snapshot(receipt_path)
          previous = validate_receipt(receipt)
          rows = rows_for(previous)
          { 'schema' => 1, 'target' => target, 'history' => history, 'receipt_path' => receipt_path,
            'receipt_before' => receipt,
            'receipt_after' => Store.content(@incoming.fetch(receipt_path), receipt.fetch('mode')),
            'files' => rows }
        end

        def validate_path(path, inspect: true)
          valid = path.is_a?(String) && path.start_with?("#{destination}/") &&
                  SkillInstaller::NAMES.include?(path.delete_prefix("#{destination}/").split('/').first) &&
                  !path.split('/').intersect?(['..', '.', ''])
          raise InstallationError, 'Receipt contains an unowned skill path.' unless valid

          store.snapshot(path) if inspect # Historical unmanaged paths are not inspected.
        end

        private

        def history
          base = ".foundry/skill-upgrades/#{target}"
          store.children(base).filter_map do |id|
            state = store.snapshot("#{base}/#{id}/state.json")
            [id, state.fetch('sha256')] if state
          end
        end

        def rows_for(previous)
          paths = (previous.keys | @incoming.keys.reject { |path| path == receipt_path }).sort
          paths.map { |path| row(path, previous[path]) }
        end

        def validate_receipt(snapshot)
          raise InstallationError, 'Upgrade requires an installed eight-skill receipt.' unless snapshot

          data = JSON.parse(Base64.strict_decode64(snapshot.fetch('content')))
          validate_shape(data)
          data.fetch('files').each do |path, hash|
            raise InstallationError, 'Invalid receipt hash.' unless hash.is_a?(String) && HASH.match?(hash)
            raise InstallationError, "Missing owned file: #{path}" unless validate_path(path)
          end
          data.fetch('files')
        rescue JSON::ParserError, KeyError, ArgumentError
          raise InstallationError, 'Malformed skill receipt; restore the reviewed original.'
        end

        def validate_shape(data)
          unless receipt_shape?(data)
            raise InstallationError, 'Unsupported skill receipt; use a complete current eight-skill catalog.'
          end

          names = data['files'].keys.filter_map do |path|
            path.delete_prefix("#{destination}/").delete_suffix('/SKILL.md') if path.end_with?('/SKILL.md')
          end
          return if names.sort == SkillInstaller::NAMES.sort

          raise InstallationError, 'Upgrade requires all eight current skills.'
        end

        def receipt_shape?(data)
          data.is_a?(Hash) && data.keys.sort == %w[files version] && data['files'].is_a?(Hash) &&
            data['version'].is_a?(String) && /\A1\.\d+\.\d+(?:[-.][\w.]+)?\z/.match?(data['version'])
        end

        def row(path, base)
          current = validate_path(path)
          raise InstallationError, "Occupied new destination: #{path}" if !base && current

          incoming = @incoming[path] && Store.content(@incoming[path], current ? current.fetch('mode') : 0o644)
          { 'path' => path, 'base' => base, 'before' => current, 'upstream' => incoming,
            'action' => classify(base, current, incoming) }
        end

        def classify(base, current, incoming)
          return 'add' unless base
          return current['sha256'] == base ? 'remove' : 'review' unless incoming

          compare_hashes(base, current['sha256'], incoming['sha256'])
        end

        def compare_hashes(base, current, incoming)
          return base == incoming ? 'unchanged' : 'current' if current == incoming
          return 'customized' if incoming == base

          current == base ? 'update' : 'review'
        end
      end
    end
  end
end
