# frozen_string_literal: true

require_relative '../test/test_helper'
require_relative 'archive_helper'

class InstalledPackageSourcesTest < FoundryTest
  include ArchiveAcceptance

  %w[packs components].each do |root|
    define_method("test_installed_source_coverage_#{root}") { verify_installed_sources(root) }
  end

  private

  def verify_installed_sources(root)
    build_archive
    prepare_host
    assert_command(RbConfig.ruby, '-S', 'gem', 'install', @archive, '--local', '--ignore-dependencies',
                   '--no-document', '--install-dir', @gem_home)
    assert_command(RbConfig.ruby, '-S', 'bundle', 'install', '--local')
    assert_provenance
    prepare_packages(root)
    before = protected_files(root)
    %w[check adopt].each { |action| assert_source_report(action, root, success: false) }
    output, error, status = command(RbConfig.ruby, 'bin/rails', 'foundry:architecture:sources')
    refute status.success?, "#{output}\n#{error}"
    assert_includes output, "#{root}/plain/app/services/reference.rb:2"
    assert_equal before, protected_files(root)
    write("app/#{root}/plain/app/services/reference.rb", "raise 'Do not execute package source'\nObject.new\n")
    %w[check adopt].each { |action| assert_source_report(action, root, success: true) }
    rails('foundry:architecture:sources')
    assert_equal before, protected_files(root)
  end

  def prepare_packages(root)
    write('app/packs.yml', "pack_paths:\n- #{root}/*\n- #{root}/*/children/*\n")
    write('app/config/foundry.yml', "workflow:\n  specs: none\n")
    write('app/openspec/changes/archive/reviewed.md', 'Existing application workflow history')
    write('app/config/initializers/do_not_boot.rb', "raise 'Source checks must not boot Rails'\n")
    write('app/app/services/shell.rb', "raise 'Do not execute shell source'\nObject.new\n")
    write("app/#{root}/plain/package.yml", "{}\n")
    write("app/#{root}/plain/children/inner/package.yml", "{}\n")
    write("app/#{root}/plain/children/inner/app/services/native.rb", "Object.new\n")
    write("app/#{root}/plain/package_todo.yml", "# Existing reviewed debt\n{}\n")
    write("app/#{root}/plain/app/services/reference.rb",
          "raise 'Do not execute package source'\nRailsAIFoundry::Conventions::Intent\n")
  end

  def assert_source_report(action, root, success:)
    output, error, status = command(RbConfig.ruby, File.join(@gem_home, 'bin/foundry'), action, '--sources',
                                    '--format=json')
    assert_equal success, status.success?, "#{output}\n#{error}"
    report = JSON.parse(output)
    assert_empty report['contexts']
    assert_includes report['packages'], "#{root}/plain/children/inner"
    assert_equal 3, report.dig('sources', 'files_checked')
    expected = success ? [] : ["#{root}/plain/app/services/reference.rb"]
    assert_equal(expected, report.dig('sources', 'diagnostics').map { |item| item['file'] })
  end

  def protected_files(root)
    ['Gemfile', 'Gemfile.lock', 'packs.yml', 'config/foundry.yml', 'openspec/changes/archive/reviewed.md',
     "#{root}/plain/package_todo.yml"].to_h do |path|
      [path, File.binread(File.join(@app, path))]
    end
  end
end
