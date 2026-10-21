# frozen_string_literal: true

require_relative '../test/test_helper'
require_relative '../test_packaging/archive_helper'
require_relative 'support/skill_upgrades'

class InstalledAIJourneyTest < FoundryTest
  include ArchiveAcceptance
  include InstalledSkillUpgrades

  def test_installed_ai_journey_default_root
    replay('packs')
  end

  def test_installed_ai_journey_custom_root
    replay('components')
  end

  private

  def replay(pack_root)
    build_archive
    @app = File.join(@root, 'app')
    @gem_home = File.join(@root, 'gems')
    FileUtils.mkdir_p(@app)
    write('network_guard.rb', '') # Consumer tests supply the loopback-only provider guard.
    assert_command(RbConfig.ruby, '-S', 'gem', 'install', @archive, '--local', '--ignore-dependencies',
                   '--no-document', '--install-dir', @gem_home)
    guide = File.read(File.join(@gem_home, 'gems', "rails_ai_foundry-#{RailsAIFoundry::VERSION}",
                                'docs/first-ai-feature.md'), encoding: Encoding::UTF_8)
    replay_snippets(guide, pack_root)
    %w[agents claude cursor].each { |target| verify_skill_upgrades(pack_root, target: target) }
    verify_preservation(pack_root)
    verify_production
  ensure
    command(RbConfig.ruby, 'bin/rails', 'db:drop') if @app && File.file?(File.join(@app, 'Gemfile.lock'))
  end

  def replay_snippets(guide, pack_root)
    snippets = guide.scan(/^```(\w+)(?: file=(\S+))? phase=(\w+)(?: source=\S+)?\n(.*?)^```/m)
    snippets.each do |language, path, _phase, body|
      body = body.gsub('packs/', "#{pack_root}/")
      if path
        write("app/#{path.gsub('packs/', "#{pack_root}/")}", body)
      else
        assert_equal 'sh', language
        body.lines.map(&:strip).reject(&:empty?).each { |line| assert_command(*Shellwords.split(line)) }
      end
    end
  end

  def verify_preservation(pack_root)
    installed = File.join(@gem_home, 'gems', "rails_ai_foundry-#{RailsAIFoundry::VERSION}")
    output = assert_command(RbConfig.ruby, '-rbundler/setup', '-e',
                            'puts Gem.loaded_specs.fetch("rails_ai_foundry").full_gem_path')
    assert_equal File.realpath(installed), File.realpath(output.strip)
    custom = '.agents/skills/foundry-add-feature/SKILL.md'
    write("app/#{custom}", 'Application-owned implementation guidance')
    write("app/#{pack_root}/assistance/package_todo.yml", "# Reviewed baseline must survive\n{}\n")
    protected = [custom, '.foundry/skills/agents.json', 'config/foundry.yml',
                 "#{pack_root}/assistance/package_todo.yml"]
    before = protected.to_h { |path| [path, File.binread(File.join(@app, path))] }
    %w[none openspec spec_kit].each do |workflow|
      config = YAML.safe_load(before.fetch('config/foundry.yml'))
      config['workflow']['specs'] = workflow
      before['config/foundry.yml'] = YAML.dump(config)
      write('app/config/foundry.yml', before.fetch('config/foundry.yml'))
      rails('generate', 'foundry:skills')
      before.each { |path, content| assert_equal content, File.binread(File.join(@app, path)) }
    end
  end

  def verify_production
    rails('runner', <<~RUBY, extra_env: { 'RAILS_ENV' => 'production', 'BUNDLE_WITHOUT' => 'development:test' })
      Rails.application.eager_load!
      raise 'Foundry loaded in production' if defined?(RailsAIFoundry)
      puts 'Native production loading passed'
    RUBY
  end
end
