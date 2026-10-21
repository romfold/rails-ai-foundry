# frozen_string_literal: true

require_relative '../test/test_helper'
require_relative '../test/support/prompt_fixtures'
require_relative 'archive_helper'

class InstalledPackagePromptsTest < FoundryTest
  include ArchiveAcceptance
  include PromptFixtures

  %w[packs components].each do |root|
    define_method("test_installed_prompt_coverage_#{root}") { verify_installed_prompts(root) }
  end

  private

  def verify_installed_prompts(root)
    build_archive
    prepare_host
    assert_command(RbConfig.ruby, '-S', 'gem', 'install', @archive, '--local', '--ignore-dependencies',
                   '--no-document', '--install-dir', @gem_home)
    assert_command(RbConfig.ruby, '-S', 'bundle', 'install', '--local')
    assert_provenance
    prepare_packages(root)
    before = protected_files(root)
    assert_prompt_report(root, success: false)
    prompt("app/#{root}/plain/app/prompts/answer", owner: "#{root}/plain")
    assert_prompt_report(root, success: true)
    prompt("app/#{root}/plain/child/app/prompts/answer", owner: "#{root}/plain")
    assert_prompt_report(root, success: false, failure: "#{root}/plain/child/app/prompts/answer/contract.yml")
    prompt("app/#{root}/plain/child/app/prompts/answer", owner: "#{root}/plain/child")
    assert_prompt_report(root, success: true)
    assert_equal before, protected_files(root)
  end

  def prepare_packages(root)
    write('app/packs.yml', "pack_paths:\n- #{root}/**\n")
    write('app/config/foundry.yml', "workflow:\n  specs: none\n")
    write('app/openspec/changes/archive/reviewed.md', 'Existing workflow history')
    write('app/config/initializers/do_not_boot.rb', "raise 'Prompt checks must not boot'\n")
    write("app/#{root}/plain/package.yml", "{}\n")
    write("app/#{root}/plain/child/package.yml", "{}\n")
    write("app/#{root}/plain/package_todo.yml", "# Reviewed debt\n{}\n")
    write('app/.foundry/agents/existing.yml', 'Application-owned receipt')
    prompt('app/app/prompts/shell', owner: '.')
    prompt("app/#{root}/plain/child/app/prompts/answer", owner: "#{root}/plain/child")
    write("app/#{root}/plain/app/prompts/answer/instructions.txt", 'Missing contract')
  end

  def assert_prompt_report(root, success:, failure: "#{root}/plain/app/prompts/answer/contract.yml")
    output, error, status = command(RbConfig.ruby, File.join(@gem_home, 'bin/foundry'), 'check', '--prompts',
                                    '--sources', '--format=json')
    assert_equal success, status.success?, "#{output}\n#{error}"
    report = JSON.parse(output)
    assert_empty report['contexts']
    assert_includes report['packages'], "#{root}/plain/child"
    assert_equal 3, report.dig('prompts', 'files_checked')
    assert report.dig('sources', 'success')
    assert_equal(success ? [] : [failure], report.dig('prompts', 'diagnostics').map { |item| item['file'] })
  end

  def protected_files(root)
    ['Gemfile', 'Gemfile.lock', 'packs.yml', 'config/foundry.yml', 'openspec/changes/archive/reviewed.md',
     '.foundry/agents/existing.yml', "#{root}/plain/package_todo.yml"].to_h do |path|
      [path, File.binread(File.join(@app, path))]
    end
  end
end
