# frozen_string_literal: true

require_relative '../test/test_helper'
require_relative 'archive_helper'

class InstalledPackageRefactorTest < FoundryTest
  include ArchiveAcceptance

  %w[packs components].each do |root|
    define_method("test_installed_refactor_#{root}") { verify_installed_refactor(root) }
  end

  private

  def verify_installed_refactor(root)
    build_archive
    prepare_host
    assert_command(RbConfig.ruby, '-S', 'gem', 'install', @archive, '--local', '--ignore-dependencies',
                   '--no-document', '--install-dir', @gem_home)
    assert_command(RbConfig.ruby, '-S', 'bundle', 'install', '--local')
    assert_provenance
    prepare_refactor(root)
    before = snapshot
    result = refactor('Billing')
    assert result['complete']
    assert_equal(["#{root}/billing/lib/owned.rb"], result['findings'].map { |item| item['file'] })
    assert_equal 'domain', result['proposed_profile']
    assert_equal 'modular', result['profile']
    result = refactor('Shell')
    assert result['complete']
    assert_equal(['app/domain/rule.rb'], result['findings'].map { |item| item['file'] })
    assert_equal before, snapshot
    write("app/#{root}/billing/test/broken.rb", 'class Broken <')
    before = snapshot
    refute refactor('Billing', success: false)['complete']
    assert_equal before, snapshot
  end

  def prepare_refactor(root)
    write('app/packs.yml', "pack_paths:\n- .\n- #{root}/**\n")
    write('app/foundry.yml', "namespace: Shell\nprofile: domain\n")
    write('app/package.yml', '{}')
    write('app/config/foundry.yml', "workflow:\n  specs: none\n")
    write('app/config/initializers/no_boot.rb', "raise 'Refactor must not boot'")
    write('app/app/domain/rule.rb', 'Rails.logger')
    write('app/tmp/ignored.rb', 'class Broken <')
    write("app/#{root}/billing/package.yml", '{}')
    write("app/#{root}/billing/foundry.yml", "namespace: Billing\nprofile: modular\n")
    write("app/#{root}/billing/lib/owned.rb", 'RailsAIFoundry::Runtime')
    write("app/#{root}/billing/child/package.yml", '{}')
    write("app/#{root}/billing/child/test/broken.rb", 'class Broken <')
    write("app/#{root}/billing/package_todo.yml", "# Accepted debt\n{}\n")
    write('app/openspec/changes/archive/reviewed.md', 'Existing workflow history')
    write('app/AGENTS.md', 'Application-owned instructions')
    write('app/.agents/skills/custom/SKILL.md', 'Custom guidance')
    write('app/.foundry/skills/existing.json', 'Existing receipt')
  end

  def refactor(context, success: true)
    output, error, status = command(RbConfig.ruby, File.join(@gem_home, 'bin/foundry'), 'plan', 'refactor',
                                    "--context=#{context}", '--profile=domain', '--format=json')
    assert_equal success, status.success?, "#{output}\n#{error}"
    result = JSON.parse(output)
    assert_equal 1, result['report_schema']
    assert_equal 'refactor', result['report_kind']
    result
  end
end
