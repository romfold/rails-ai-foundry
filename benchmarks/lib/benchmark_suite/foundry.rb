# frozen_string_literal: true

require 'tmpdir'
require_relative 'corpus'
require_relative 'delivery_variants'
require_relative 'patches'

module BenchmarkSuite
  class Foundry
    def self.prepare(destination)
      new(destination).prepare
    end

    def initialize(destination)
      @root = Support.external_directory(destination)
    end

    def prepare
      @root.join('tasks').mkpath
      gem = @root.join('rails_ai_foundry.gem')
      Support.run('gem', 'build', 'rails_ai_foundry.gemspec', '--output', gem.to_s, directory: REPOSITORY)
      Corpus::TASKS.product(Corpus::GROUPS).each { |task, group| prepare_task(task, group, gem) }
      @root.join('bench.yml').write(configuration.to_yaml)
      manifest(gem)
      @root
    end

    private

    def configuration
      {
        'version' => 1, 'environment' => { 'backend' => 'docker', 'workdir' => '/candidate',
                                           'network' => { 'mode' => 'none' }, 'build_timeout' => '30m' },
        'agent' => { 'name' => 'nop', 'model' => 'offline-controls', 'timeout' => '10m',
                     'environment' => { 'network' => { 'mode' => 'none' } } },
        'verifier' => { 'timeout' => '10m', 'command' => 'ruby /tests/verify.rb',
                        'restore' => %w[Gemfile Gemfile.lock AGENTS.md TASK.md test] }
      }
    end

    def manifest(gem)
      Support.json(@root.join('manifest.json'), { 'suite' => 'foundry', 'lemans_revision' => LEMANS_REVISION,
                                                  'gem_sha256' => Digest::SHA256.file(gem).hexdigest,
                                                  'skills' => Support.files(REPOSITORY.join('skills')),
                                                  'files' => Support.files(@root) })
    end

    def prepare_task(task, group, gem)
      directory = @root.join('tasks', "#{task}-#{group}")
      environment = directory.join('environment')
      environment.mkpath
      Corpus.materialize(environment.join('candidate'), task, group)
      FileUtils.cp(gem, environment.join('foundry.gem')) if group == 'foundry'
      environment.join('Dockerfile').write(dockerfile(group))
      verification_files(directory, task, group)
      solution_files(directory, task, group)
    end

    def verification_files(directory, task, group)
      directory.join('instruction.md').write("---\nmetadata:\n  task: #{task}\n  group: #{group}\n---\n" +
                                              ROOT.join('tasks/v1', task, 'requirements.md').read)
      tests = directory.join('tests')
      tests.mkpath
      FileUtils.cp_r(ROOT.join('evaluator').children, tests)
      FileUtils.cp(ROOT.join('verification/verify.rb'), tests)
      tests.join('task.json').write(JSON.generate('task' => task, 'group' => group))
    end

    def solution_files(directory, task, group)
      Patches.write(directory, task, group, 'reference', filename: 'solution.patch')
      Patches.write(directory, task, group, 'faulty', filename: 'faulty.patch')
      return unless task == 'boundary-extraction'

      DeliveryVariants::NAMES.each do |variant|
        Patches.write(directory, task, group, variant, filename: "#{variant}.patch")
      end
    end

    def install_gem(group)
      return '' unless group == 'foundry'

      "COPY foundry.gem /tmp/foundry.gem\n" \
        "RUN gem install --local /tmp/foundry.gem --ignore-dependencies --no-document && rm /tmp/foundry.gem\n"
    end

    def install_skills(group)
      return '' unless group == 'foundry'

      'RUN bundle exec ruby -rrails_ai_foundry/generation/skill_installer ' \
        "-e 'RailsAIFoundry::Generation::SkillInstaller.new(Dir.pwd).call'\n"
    end

    def dockerfile(group)
      install = install_gem(group)
      skills = install_skills(group)
      <<~DOCKER
        FROM ruby@sha256:9d50d98e61ccbe4f1ef436349911e09b53c42a00364bcd3bda6ac107abc29528
        RUN apt-get update && apt-get install -y --no-install-recommends git build-essential libyaml-dev pkg-config && rm -rf /var/lib/apt/lists/*
        WORKDIR /candidate
        #{install}COPY candidate/Gemfile candidate/Gemfile.lock ./
        RUN bundle install
        COPY candidate/ ./
        RUN bundle lock --local
        #{skills}RUN git init -q && git add -A && git -c user.name=Benchmark -c user.email=benchmark@example.invalid commit -qm 'Initial commit'
        ENV RAILS_ENV=test HOME=/tmp/home
      DOCKER
    end
  end
end
