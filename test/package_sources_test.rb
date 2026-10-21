# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/package_sources'

class PackageSourcesTest < FoundryTest
  def test_root_custom_nested_and_overlapping_roots_are_normalized
    paths = %w[app/models/root.rb components/a/app/models/a.rb components/a/child/app/models/b.rb
               app/domain/embedded/app/models/c.rb]
    paths.each { |path| write(path, 'Object') }
    write('components/a/child/test/not_source.rb', 'class Broken <')
    write('app/domain/embedded/lib/not_source.rb', 'class Broken <')
    write('components/a/lib/not_source.rb', 'class Broken <')
    inventory = inventory_for(%w[. ./components/a components/a components/a/child app/domain/embedded components/empty])
    assert_equal paths.sort, inventory.paths
    assert_equal 'components/a/child', inventory.owner(paths[2])
    assert_equal '.', inventory.owner('components/abc/app/model.rb')
    assert_equal '.', inventory.owner('app/models/root.rb')
    assert_equal inventory.paths, inventory.paths
  end

  def test_empty_roots_and_shell_only_sources
    assert_empty inventory_for([]).paths
    write('app/models/record.rb', 'Object')
    assert_equal ['app/models/record.rb'], inventory_for([]).paths
    assert_nil inventory_for([]).owner('app/models/record.rb')
  end

  def test_package_at_an_app_root_is_not_treated_as_its_parents_app_tree
    write('app/models/not_source.rb', 'class Broken <')
    write('app/app/models/source.rb', 'Object')
    write('packs/parent/app/models/not_source.rb', 'class Broken <')
    write('packs/parent/app/app/models/source.rb', 'Object')
    assert_equal %w[app/app/models/source.rb packs/parent/app/app/models/source.rb],
                 inventory_for(%w[app packs/parent packs/parent/app]).paths
  end

  def test_invalid_package_inventory_is_rejected
    [nil, 'packs/a', [nil], [''], ['/outside'], ['../outside'], ['packs/../outside'], ["packs/a\0"]].each do |paths|
      assert_raises(RailsAIFoundry::ConfigurationError) { inventory_for(paths) }
    end
  end

  def test_source_and_directory_links_are_rejected_without_following
    write('outside/secret.rb', 'private synthetic content')
    %w[app/link.rb app/subdirectory components/a/app].each do |path|
      FileUtils.mkdir_p(File.dirname(File.join(@root, path)))
      target = path.end_with?('.rb') ? 'outside/secret.rb' : 'outside'
      File.symlink(File.join(@root, target), File.join(@root, path))
      error = assert_raises(RailsAIFoundry::ConfigurationError) { inventory_for(['components/a']).paths }
      assert_includes error.message, 'Symbolic links'
      refute_includes error.message, 'private synthetic content'
      File.unlink(File.join(@root, path))
    end
  end

  def test_symlinked_package_is_rejected
    FileUtils.mkdir_p(File.join(@root, 'outside'))
    File.symlink(File.join(@root, 'outside'), File.join(@root, 'linked'))
    assert_raises(RailsAIFoundry::ConfigurationError) { inventory_for(['linked']) }
  end

  def test_non_directory_and_failed_enumeration_fail_explicitly
    write('app', 'not a directory')
    assert_raises(RailsAIFoundry::ConfigurationError) { inventory_for([]).paths }
    File.unlink(File.join(@root, 'app'))
    write('app/models/record.rb', 'Object')
    Dir.stub(:children, ->(*) { raise Errno::EACCES }) do
      error = assert_raises(RailsAIFoundry::ConfigurationError) { inventory_for([]).paths }
      assert_equal 'Cannot enumerate source directory: app', error.message
    end
  end

  private

  def inventory_for(packages)
    RailsAIFoundry::Conventions::PackageSources.new(RailsAIFoundry::Conventions::Files.new(@root), packages: packages)
  end
end
