# frozen_string_literal: true

require 'bundler'
require 'digest'
require 'fileutils'
require 'json'
require 'open3'
require 'rbconfig'
require 'rubygems/package'
require 'shellwords'
require 'tmpdir'
require 'yaml'
require_relative 'checkpoints'
require_relative 'replay_host'

module KnowledgeAdoption
  SOURCE = File.expand_path('../../..', __dir__)
  FIXTURE = File.expand_path('../starting_app', __dir__)
  INTEGRATION = File.join(SOURCE, 'recipes/domain-knowledge-rag-rom-res-elasticsearch-pgvector')

  class Replay
    include Checkpoints
    include ReplayHost

    def initialize
      @directory = File.realpath(Dir.mktmpdir('foundry-knowledge-adoption-'))
      @gem_home = File.join(@directory, 'gems')
      @results = []
    end

    def call
      install_archive
      %w[packs components].each { |root| replay(root) }
      File.write(File.join(@directory, 'evidence.json'), JSON.pretty_generate(@results))
      puts "Adoption evidence retained at #{@directory}"
    rescue StandardError
      warn "Failed checkpoint preserved at #{@directory}"
      raise
    end

    private

    def replay(root)
      prepare_application(root)
      verify('01-characterize')
      assess
      extraction_checkpoints(root)
      introduce_rom
      verify('05-rom')
      introduce_integrations(root)
      command('bundle', 'exec', 'rails', 'db:prepare')
      verify('06-integrations')
      verify_integrations
    end

    def extraction_checkpoints(root)
      extract(root)
      verify('03-extract')
      verify_recovery_guidance
      accept_temporary_debt
      repair_callers
      resolve_debt
      verify('04-public-api')
    end

    def prepare_application(root)
      @pack = nil
      @app = File.join(@directory, root)
      FileUtils.cp_r(FIXTURE, @app)
      @database = "foundry_adoption_#{Process.pid}_#{root}"
      @workflow = hashes('openspec/**/*')
      gemfile = File.read(File.join(@app, 'Gemfile')).sub("path: '../../..'", "'1.0.0', require: false")
      write('Gemfile', gemfile)
      command('bundle', 'install', '--local', frozen: false)
      command('bundle', 'exec', 'rails', 'db:prepare')
      seed
    end

    def verify(checkpoint)
      verify_continuity
      command('bundle', 'exec', 'rails', 'test')
      command('bundle', 'exec', 'rails', 'runner', 'Rails.application.eager_load!')
      verify_assessment if @pack
      command(File.join(SOURCE, 'node_modules/.bin/openspec'), 'validate', '--all', '--strict', '--no-interactive')
      verify_continuity
      raise 'Established workflow changed' unless @workflow == hashes('openspec/**/*')

      snapshot = File.join(@directory, 'checkpoints', File.basename(@app), checkpoint)
      FileUtils.mkdir_p(File.dirname(snapshot))
      FileUtils.cp_r(@app, snapshot)
      @results << { snapshot: snapshot, checkpoint: checkpoint, root: @app,
                    gem_sha256: @archive_hash, database: @database,
                    workflow_sha256: @workflow, source_sha256: hashes('{app,config,packs,components}/**/*') }
    end

    def verify_assessment
      output = command('bundle', 'exec', 'foundry', 'plan', 'refactor', "--context=#{@pack}", '--format=json')
      raise 'Incomplete context assessment' unless JSON.parse(output).fetch('complete')
    end

    def assess
      before = hashes('**/*')
      report = JSON.parse(command('bundle', 'exec', 'foundry', 'adopt', '--format=json'))
      raise 'Wrong workflow selection' unless report['workflow'] == 'openspec' && report['workflow_initialized']
      raise 'Assessment changed application files' unless before == hashes('**/*')

      location = command('bundle', 'exec', 'ruby', '-e',
                         'puts Gem.loaded_specs.fetch("rails_ai_foundry").full_gem_path').strip
      raise 'Replay used source checkout' unless location.start_with?(@gem_home)

      @results << { checkpoint: '02-assess', report: report, installed_gem: location }
    end

    def verify_recovery_guidance
      command('bundle', 'exec', 'rails', 'generate', 'foundry:skills')
      reference = File.join(@app, '.agents/skills/foundry-verify/references/behavioral-recovery.md')
      raise 'Missing installed recovery guidance' unless File.file?(reference)
      raise 'Workflow history changed during skill installation' unless @workflow == hashes('openspec/**/*')
    end

    def accept_temporary_debt
      command('bundle', 'exec', 'ruby', '-rstringio', '-S', 'packwerk', 'check', expected: 1)
      command('bundle', 'exec', 'ruby', '-rstringio', '-S', 'packwerk', 'update-todo')
      @debt = hashes('**/package_todo.yml')
      raise 'Expected an explicit temporary caller violation' if @debt.empty?

      review_temporary_debt
      command('bundle', 'exec', 'foundry', 'check', '--boundaries')
      raise 'Normal checking changed accepted debt' unless @debt == hashes('**/package_todo.yml')
    end

    def review_temporary_debt
      report = JSON.parse(command('bundle', 'exec', 'foundry', 'adopt', '--format=json'))
      @accepted = report.fetch('accepted_debt')
      return if @accepted.size == 1 && @accepted.first.to_json.include?('Knowledge::Catalog')

      raise 'Unexpected temporary debt'
    end

    def resolve_debt
      report = JSON.parse(command('bundle', 'exec', 'foundry', 'audit'))
      unless report['resolved'] == @accepted && report['new'].empty?
        raise 'Caller repair did not resolve exactly the reviewed debt'
      end
      raise 'Audit changed source baseline' unless @debt == hashes('**/package_todo.yml')

      @debt.each_key { |path| FileUtils.rm(File.join(@app, path)) }
      @results << { checkpoint: '04-reviewed-debt', resolved: report['resolved'] }
      command('bundle', 'exec', 'foundry', 'check', '--boundaries')
    end
  end
end
