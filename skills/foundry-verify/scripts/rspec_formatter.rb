# frozen_string_literal: true

require 'json'
require 'pathname'
require_relative 'loaded_files'

module FoundrySkillVerification
  class RSpecFormatter
    RSpec::Core::Formatters.register self, :start, :example_started, :example_passed, :example_failed,
                                     :example_pending, :dump_summary, :close

    def initialize(_output)
      @report = { 'version' => 1, 'framework' => 'rspec', 'started' => [], 'examples' => [],
                  'complete' => false, 'errors' => 0, 'problems' => [] }
    end

    def start(notification)
      @report['expected'] = notification.count
      @report['problems'] = configuration_problems
      all = RSpec.world.example_groups.flat_map(&:descendants).flat_map(&:examples)
      @report['problems'] << 'filtered examples' unless all.size == notification.count
      reject_narrowed_baseline
    end

    def example_started(notification)
      @report['started'] << notification.example.id
    end

    def example_passed(notification)
      record(notification.example, 'pass')
    end

    def example_failed(notification)
      record(notification.example, 'fail')
    end

    def example_pending(notification)
      record(notification.example, 'pending')
    end

    def dump_summary(notification)
      @report['errors'] = RSpec.world.non_example_failure ? 1 : 0
      @report['complete'] = !RSpec.world.wants_to_quit && notification.example_count == @report['examples'].size
    end

    def close(_notification)
      @report['loaded_files'] = LoadedFiles.relative(RSpec.configuration.loaded_spec_files.to_a)
      File.write(ENV.fetch('FOUNDRY_TEST_EVIDENCE'), JSON.generate(@report))
    end

    private

    def reject_narrowed_baseline
      return unless ENV['FOUNDRY_PACKAGE_BASELINE'] && !@report['problems'].empty?

      raise 'Unsupported narrowed RSpec discovery; remove filters, custom patterns and dry-run settings.'
    end

    def configuration_problems
      config = RSpec.configuration
      filters = config.filter_manager
      checks = { 'dry-run' => config.dry_run, 'only failures' => config.only_failures,
                 'excluded files' => !config.exclude_pattern.to_s.empty?,
                 'custom file pattern' => config.pattern != '**{,/*/**}/*_spec.rb',
                 'active filters' => !(filters.inclusions.empty? && filters.exclusions.empty?) }
      checks.select { |_, active| active }.keys
    end

    def record(example, status)
      metadata = example.metadata
      # RSpec's rerun path belongs to the including group for shared examples.
      owner = metadata[:rerun_file_path] || metadata[:file_path]
      @report['examples'] << { 'id' => example.id, 'status' => status, 'type' => metadata[:type].to_s,
                               'files' => owner ? [relative(owner)] : [] }
    end

    def relative(path)
      Pathname(File.expand_path(path)).relative_path_from(Pathname(Dir.pwd)).to_s
    end
  end
end
