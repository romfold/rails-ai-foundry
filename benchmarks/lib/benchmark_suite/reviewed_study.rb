# frozen_string_literal: true

require_relative 'patches'
require 'rubygems/package'
require_relative 'reviewed_study_files'

module BenchmarkSuite
  class ReviewedStudy
    include ReviewedStudyFiles

    GROUPS = %w[packs foundry].freeze
    SERVICES = %w[request_resolution review_resolution generate_resolution execute_resolution].freeze
    VARIANTS = %w[reference delegated bypass_approval ignore_revision stale_generation duplicate_execution noop].freeze

    def self.prepare(destination)
      new(destination).prepare
    end

    def initialize(destination)
      @root = Support.external_directory(destination)
    end

    def prepare
      gem = @root.join('rails_ai_foundry.gem')
      Support.run('gem', 'build', 'rails_ai_foundry.gemspec', '--output', gem.to_s, directory: REPOSITORY)
      GROUPS.each { |group| prepare_task(group, gem) }
      @root.join('bench.yml').write(configuration.to_yaml)
      write_manifest(gem)
      Lemans::Config.load_file(@root)
      @root
    end

    private

    def write_manifest(gem)
      Support.json(@root.join('manifest.json'), {
                     'suite' => 'reviewed-ai-v1', 'execution_authorized' => false,
                     'proposed_trials' => 6, 'repetitions_per_group' => 3, 'trial_timeout_seconds' => 1200,
                     'lemans_revision' => LEMANS_REVISION, 'gem_sha256' => Digest::SHA256.file(gem).hexdigest,
                     'skills' => Support.files(REPOSITORY.join('skills')), 'files' => Support.files(@root)
                   })
    end

    def prepare_task(group, gem)
      task = @root.join('tasks', "reviewed-ai-#{group}")
      environment = task.join('environment')
      environment.mkpath
      candidate = environment.join('candidate')
      materialize(candidate, group)
      FileUtils.cp(gem, environment.join('foundry.gem'))
      cache_dependencies(environment)
      environment.join('Dockerfile').write(dockerfile(group))
      write_instruction(task, group)
      verifier_files(task, group)
      write_solutions(task)
    end

    def write_instruction(task, group)
      task.join('instruction.md').write("---\nmetadata:\n  task: reviewed-ai-v1\n  group: #{group}\n---\n" +
                                          ROOT.join('reviewed-ai/v1/requirements.md').read)
    end

    def cache_dependencies(environment)
      cache = environment.join('gems')
      cache.mkpath
      cached_dependencies.each { |path| FileUtils.cp(path, cache.join(File.basename(path))) }
    end

    def cached_dependencies
      names = dependency_names
      Gem.path.flat_map { |path| Dir[File.join(path, 'cache/*.gem')] }.select do |path|
        spec = Gem::Package.new(path).spec
        spec.name != 'rails_ai_foundry' && spec.platform == Gem::Platform::RUBY && names.include?([spec.name,
                                                                                                   spec.version.to_s])
      end
    end

    def dependency_names
      lock = REPOSITORY.join('examples/rails-native-agent-tools-structured-output-rubyllm/Gemfile.lock').read
      Bundler::LockfileParser.new(lock).specs.map { |spec| [spec.name, spec.version.to_s] }
    end

    def materialize(candidate, group)
      candidate.mkpath
      snippets.each do |path, body|
        next if path.start_with?('test/') || path == 'bin/verify-controls'

        target = candidate.join(path)
        target.dirname.mkpath
        target.write(body)
      end
      prepare_candidate(candidate, group)
      stub_services(candidate)
    end

    def stub_services(candidate)
      SERVICES.each do |service|
        constant = service.split('_').map(&:capitalize).join
        candidate.join(service_path(service)).write("module SupportDesk; class #{constant}; " \
                                                    "def self.call(*, **); raise NotImplementedError; end; end; end\n")
      end
    end

    def snippets
      guide = REPOSITORY.join('docs/first-ai-feature.md').read(encoding: Encoding::UTF_8)
      guide.scan(/^```\w+ file=(\S+) phase=\w+ source=\S+\n(.*?)^```/m).to_h.transform_keys { |path| adapt(path) }
           .transform_values { |body| adapt(body) }
    end

    def write_solutions(task)
      VARIANTS.each do |variant|
        Dir.mktmpdir('reviewed-solution-') do |temporary|
          work = Patches.baseline(task, temporary)
          restore_solution(work, variant)
          Support.run('git', '-C', work.to_s, 'add', '-A')
          patch = task.join(variant == 'reference' ? 'solution.patch' : "#{variant}.patch")
          Support.run('git', '-C', work.to_s, 'diff', '--cached', '--binary', '--output', patch.to_s)
        end
      end
    end

    def restore_solution(work, variant)
      return if variant == 'noop'

      SERVICES.each { |service| work.join(service_path(service)).write(snippets.fetch(service_path(service))) }
      add_variant(work, variant)
    end

    def adapt(text)
      text.gsub('packs/', 'components/').gsub('Assistance', 'SupportDesk').gsub('assistance', 'support_desk')
    end

    def service_path(name)
      "components/support_desk/app/services/support_desk/#{name}.rb"
    end

    def add_variant(work, variant)
      return if variant == 'reference'

      source = adapt(ROOT.join('reviewed-ai/v1/variants', "#{variant}.rb").read)
      target = variant == 'stale_generation' ? 'generate_resolution' : 'execute_resolution'
      work.join(service_path(target)).open('a') { |file| file.write("\n#{source}") }
    end
  end
end
