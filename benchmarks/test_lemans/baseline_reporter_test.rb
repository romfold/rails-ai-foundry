# frozen_string_literal: true

require 'minitest/autorun'
require 'json'
require 'open3'
require 'rbconfig'
require 'tmpdir'

class BaselineReporterTest < Minitest::Test
  def capture(assertion)
    Dir.mktmpdir do |directory|
      script = "require 'minitest/autorun'; class SampleTest < Minitest::Test; " \
               "def test_behavior = assert(#{assertion}); def test_optional = skip('upstream skip'); end"
      environment = { 'FOUNDRY_BASELINE_CHECKS' => '1', 'LOGS' => directory }
      path = File.expand_path('../verification', __dir__)
      _stdout, _stderr, status = Open3.capture3(environment, RbConfig.ruby, "-I#{path}", '-rfoundry_baseline', '-e',
                                                script)
      [status, JSON.parse(File.read(File.join(directory, 'checks.json'))).fetch('checks')]
    end
  end

  def test_existing_application_skips_keep_native_semantics
    status, checks = capture('true')
    assert status.success?
    assert_equal %w[pass skip], checks.values.sort
  end

  def test_baseline_failure_has_structured_evidence
    status, checks = capture('false')
    refute status.success?
    assert_equal %w[fail skip], checks.values.sort
  end
end
