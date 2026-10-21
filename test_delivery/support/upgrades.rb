# frozen_string_literal: true

module DeliveryUpgrades
  private

  def verify_delivery_upgrades
    %w[agents claude cursor].each { |target| verify_delivery_upgrade(target) }
  end

  def verify_delivery_upgrade(target)
    rails('generate', 'foundry:skills', "--target=#{target}") unless target == 'agents'
    receipt_path = ".foundry/skills/#{target}.json"
    skill = ".#{target}/skills/foundry-adopt-existing-app/SKILL.md"
    prepare_delivery_predecessor(receipt_path, skill)
    protected = preserve_application_guidance(target)
    original_receipt = File.binread(File.join(@app, receipt_path))
    assessment = rails('generate', 'foundry:skills', '--upgrade', "--target=#{target}")
    digest = assessment.match(/Review digest: ([0-9a-f]{64})/)[1]
    output, error, status = command(RbConfig.ruby, 'bin/rails', 'generate', 'foundry:skills', '--upgrade',
                                    "--target=#{target}", "--apply=#{digest}")
    refute status.success?, output
    assert_includes error, 'review pending'
    assert_equal original_receipt, File.binread(File.join(@app, receipt_path))
    resolve_delivery_upgrade(target, digest)
    verify_accepted_guidance(target, receipt_path, skill, protected)
  end

  def prepare_delivery_predecessor(receipt_path, skill)
    receipt = JSON.parse(File.read(File.join(@app, receipt_path)))
    receipt['files'].keys.grep(%r{/references/delivery-extraction\.md\z}).each do |path|
      FileUtils.rm(File.join(@app, path))
      receipt['files'].delete(path)
    end
    references = %r{/references/(?:native-conventions|planning|adoption-checkpoints)\.md\z}
    receipt['files'].keys.grep(references).each do |path|
      previous = 'Previous complete-catalog guidance before package ownership coverage'
      write("app/#{path}", previous)
      receipt['files'][path] = Digest::SHA256.hexdigest(previous)
    end
    prior = 'Previous complete-catalog adoption instructions'
    write("app/#{skill}", prior)
    receipt['files'][skill] = Digest::SHA256.hexdigest(prior)
    write("app/#{receipt_path}", JSON.pretty_generate(receipt))
    write("app/#{skill}", 'Application-owned extraction policy')
  end

  def preserve_application_guidance(target)
    write('app/AGENTS.md', 'Keep the existing application authentication')
    write('app/.agents/skills/local/SKILL.md', 'Unrelated application skill')
    write("app/#{@pack_root}/search/package_todo.yml", "# Reviewed baseline; never regenerate\n{}\n")
    config = YAML.safe_load_file(File.join(@app, 'config/foundry.yml'))
    config['workflow']['specs'] = { 'agents' => 'none', 'claude' => 'openspec', 'cursor' => 'spec_kit' }.fetch(target)
    write('app/config/foundry.yml', YAML.dump(config))
    paths = ['AGENTS.md', '.agents/skills/local/SKILL.md', 'config/foundry.yml',
             "#{@pack_root}/search/package_todo.yml", 'Gemfile.lock']
    paths.to_h { |path| [path, File.binread(File.join(@app, path))] }
  end

  def resolve_delivery_upgrade(target, digest)
    relative = ".foundry/skill-upgrades/#{target}/#{digest}/decisions.json"
    decisions = JSON.parse(File.read(File.join(@app, relative)))
    decisions.fetch('files').each_value { |entry| entry['decision'] = 'keep_local' }
    write("app/#{relative}", JSON.pretty_generate(decisions))
    rails('generate', 'foundry:skills', '--upgrade', "--target=#{target}", "--resolve=#{relative}")
  end

  def verify_accepted_guidance(target, receipt_path, skill, protected)
    receipt = File.binread(File.join(@app, receipt_path))
    rails('generate', 'foundry:skills', "--target=#{target}")
    assert_equal receipt, File.binread(File.join(@app, receipt_path))
    assert_equal 'Application-owned extraction policy', File.binread(File.join(@app, skill))
    protected.each { |path, content| assert_equal content, File.binread(File.join(@app, path)) }
    refute_equal Digest::SHA256.hexdigest(File.binread(File.join(@app, skill))), JSON.parse(receipt)['files'][skill]
    reference = ".#{target}/skills/foundry-adopt-existing-app/references/delivery-extraction.md"
    assert_includes File.read(File.join(@app, reference)), 'asset pipeline'
    conventions = ".#{target}/skills/foundry-verify/references/native-conventions.md"
    assert_includes File.read(File.join(@app, conventions)), 'including packages without foundry.yml'
    planning = ".#{target}/skills/foundry-plan/references/planning.md"
    assert_includes File.read(File.join(@app, planning)), 'Independently discovered nested packages are excluded'
    adoption = ".#{target}/skills/foundry-verify/references/adoption-checkpoints.md"
    assert_includes File.read(File.join(@app, adoption)), 'one verified capture'
    assert_equal 8, Dir[File.join(@app, ".#{target}/skills/foundry-*/SKILL.md")].size
    wrapper = File.read(File.join(@app, 'bin/verify-feature')).sub(%r{\.(?:agents|claude|cursor)/skills/},
                                                                   ".#{target}/skills/")
    write('app/bin/verify-feature', wrapper)
    assert_includes assert_command(RbConfig.ruby, 'bin/verify-feature'), 'Selected feature verification passed'
  end
end
