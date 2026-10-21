# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../test_packaging/archive_helper'
require_relative '../script/privacy_check'
require 'pathname'

class DistributionIntegrityTest < FoundryTest
  include ArchiveAcceptance

  def test_contaminated_tree_cannot_expand_archive
    build_archive
    original = Gem::Package.new(@archive).contents.sort
    %w[docs/research/private.md docs/local-notes.md docs/secret.key lib/private.key .env
       config/master.key .foundry/skill-upgrades/agents/private/plan.json].each do |path|
      write("build/#{path}", 'synthetic-private-material')
    end
    rebuilt = Dir.chdir(File.join(@root, 'build')) do
      Gem::Package.build(Gem::Specification.load('rails_ai_foundry.gemspec'))
    end
    assert_equal original, Gem::Package.new(File.join(@root, 'build', rebuilt)).contents.sort
    assert_includes original, 'docs/privacy-sanitization.json'
    assert_empty original.grep(%r{\A(?:docs/research|benchmarks|examples|test|\.cursor)/})
    verify_links(original)
  end

  def test_privacy_patterns_report_categories_without_values
    samples = [['', 'Users', 'private-person', 'file'].join('/'), ['sk-proj-', 'a' * 32].join,
               ['-----BEGIN ', 'PRIVATE KEY', '-----'].join, "Bearer #{'a' * 30}"]
    samples.each { |sample| refute_empty PrivacyCheck.findings(sample) }
    assert_empty PrivacyCheck.findings('offline-placeholder demo-reader ENV.fetch("API_KEY") $HOME/bin')
    system('git', 'init', '-q', @root, exception: true)
    write('evidence.txt', samples.join("\n"))
    output = StringIO.new
    refute PrivacyCheck.clean?(@root, output: output)
    assert_includes output.string, 'evidence.txt:1: workstation_path'
    samples.each { |sample| refute_includes output.string, sample }
  end

  private

  def verify_links(contents)
    contents.grep(/\.md\z/).each do |path|
      text = File.read(File.join(@root, 'build', path), encoding: Encoding::UTF_8)
      text.scan(/\[[^\]\n]+\]\(([^\s)]+)(?:\s+"([^"]*)")?\)/).each do |target, title|
        verify_link(contents, path, target, title)
      end
    end
  end

  def verify_link(contents, path, target, title)
    target = target.split('#').first
    return if target.nil? || target.empty? || target.include?(':')

    resolved = Pathname(File.join(File.dirname(path), target)).cleanpath.to_s
    if resolved.start_with?('skills/') && !contents.include?(resolved)
      resolved = resolved.sub(%r{skills/[^/]+/references/}, 'skills/references/')
    end
    if title == 'Repository-only reference; not installed'
      assert_match(%r{\A(?:examples|recipes|benchmarks|openspec|test|script|docs/evidence|\.github)/}, resolved)
    else
      assert_includes contents, resolved, "#{path} has an unavailable installed link"
    end
  end
end
