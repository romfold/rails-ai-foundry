# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../script/validate_examples'

class ExampleCatalogTest < FoundryTest
  def setup
    super
    write('catalog.yml', "- location: modular-demo\n  focal_context: packs/billing\n")
    write('modular-demo/packs/billing/foundry.yml', "profile: modular\n")
    write('modular-demo/README.md', '[Focal context](packs/billing/foundry.yml)')
  end

  def test_reads_focal_profile_and_rejects_mismatch
    assert_equal ['modular-demo'], ExampleCatalog.validate(@root)
    write('modular-demo/packs/billing/foundry.yml', "profile: domain\n")
    assert_match(/does not match focal profile domain/, assert_raises(RuntimeError) do
      ExampleCatalog.validate(@root)
    end.message)
  end

  def test_missing_configuration_link_and_duplicate_locations_fail
    write('modular-demo/README.md', 'Missing link')
    assert_raises(RuntimeError) { ExampleCatalog.validate(@root) }
    write('modular-demo/README.md', '[Focal context](packs/billing/foundry.yml)')
    write('catalog.yml', File.read(File.join(@root, 'catalog.yml')) * 2)
    assert_raises(RuntimeError) { ExampleCatalog.validate(@root) }
  end
end
