# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/generation/scaffold_installer'

class ScaffoldInstallerTest < FoundryTest
  def test_existing_artifacts_without_receipt_fail_as_a_collision
    write('app/one.rb', '# existing')
    installer = RailsAIFoundry::Generation::ScaffoldInstaller.new(@root)
    error = assert_raises(RailsAIFoundry::InstallationError) do
      installer.install_files({ 'app/one.rb' => '# generated' })
    end
    assert_includes error.message, 'Conflicting or partial scaffold'
    assert_equal '# existing', File.read(File.join(@root, 'app/one.rb'))
  end

  def test_failed_publication_removes_new_files_but_preserves_concurrent_edits
    installer = RailsAIFoundry::Generation::ScaffoldInstaller.new(@root)
    publish = lambda do
      write('app/one.rb', '# concurrent edit')
      raise RailsAIFoundry::InstallationError, 'publication failed'
    end
    error = assert_raises(RailsAIFoundry::InstallationError) do
      installer.install_files({ 'app/one.rb' => '# generated', '.foundry/receipt.yml' => 'pending' }, publish: publish)
    end
    assert_includes error.message, 'Preserved changed'
    assert_equal({ 'app/one.rb' => '# concurrent edit' }, snapshot)
  end
end
