# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/refactor'

class PackageRefactorControlsTest < FoundryTest
  def setup
    super
    write('packs.yml', "pack_paths:\n- packs/**\n")
    write('packs/a/package.yml', '{}')
    write('packs/a/foundry.yml', "namespace: A\nprofile: modular\n")
    write('packs/a/lib/owned.rb', 'RailsAIFoundry::Runtime')
    write('packs/a/app/queries/query.rb', 'A::Record.update_all(active: true)')
    write('packs/a/child/package.yml', '{}')
    write('packs/a/child/test/broken.rb', 'class Broken <')
    write('packs/a/child/app/models/record.rb', 'class A::Record < ApplicationRecord; end')
  end

  def test_behavioral_oracle_rejects_child_inclusion_app_only_and_model_contamination
    refactor = RailsAIFoundry::Conventions::Refactor.new(@root)
    oracle(refactor.call(context: 'A'))
    original = refactor.method(:context_sources)
    faults = [
      ->(pack) { original.call(pack).merge('packs/a/child/test/broken.rb' => 'class Broken <') },
      ->(pack) { original.call(pack).reject { |path, _| path.include?('/lib/') } },
      lambda { |pack|
        original.call(pack).merge('packs/a/child/app/models/record.rb' => 'class A::Record < ApplicationRecord; end')
      }
    ]
    faults.each do |fault|
      refactor.stub(:context_sources, fault) do
        assert_raises(Minitest::Assertion) { oracle(refactor.call(context: 'A')) }
      end
    end
    refactor.stub(:context_sources, ->(pack) { original.call(pack).sort.reverse.to_h }) do
      oracle(refactor.call(context: 'A'))
    end
  end

  private

  def oracle(result)
    assert result.fetch('complete')
    assert_equal(['packs/a/lib/owned.rb'], result.fetch('findings').map { |item| item['file'] })
    assert_equal(['source.foundry_dependency'], result.fetch('findings').map { |item| item['rule'] })
  end
end
