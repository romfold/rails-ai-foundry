# frozen_string_literal: true

require_relative 'test_helper'

class NativeGeneratorIsolationTest < FoundryTest
  def setup
    super
    FileUtils.cp_r(Dir[File.expand_path('dummy/*', __dir__)], @root)
    write('Gemfile', '# Managed offline bundle')
    write('config/foundry.yml', "workflow:\n  specs: none\n")
  end

  def test_native_generation_does_not_require_legacy_implementation
    generate('context', 'billing')
    %w[operation command query model controller job mailer channel].each do |kind|
      generate(kind, "sample_#{kind}", '--context=billing')
    end
    assert File.file?(File.join(@root, 'packs/billing/app/models/billing/sample_model.rb'))
  end

  private

  def generate(kind, name, *options)
    env = { 'BUNDLE_GEMFILE' => File.expand_path(ENV.fetch('BUNDLE_GEMFILE', 'Gemfile')) }
    probe = File.expand_path('support/native_generator_isolation.rb', __dir__)
    output, error, status = Open3.capture3(env, RbConfig.ruby, '-r', probe, 'bin/rails', 'generate',
                                           "foundry:#{kind}", name, *options, chdir: @root)
    assert status.success?, "#{output}\n#{error}"
  end
end
