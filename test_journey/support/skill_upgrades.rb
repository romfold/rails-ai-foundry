# frozen_string_literal: true

module InstalledSkillUpgrades
  private

  def verify_skill_upgrades(pack_root, target: pack_root == 'packs' ? 'agents' : 'cursor')
    rails('generate', 'foundry:skills', "--target=#{target}") if target != 'agents'
    @upgrade_base = ".#{target}/skills/foundry-verify"
    @upgrade_ai = ".#{target}/skills/foundry-architecture-review/references/ai.md"
    @upgrade_receipt = ".foundry/skills/#{target}.json"
    paths = prepare_prior_catalog(pack_root)
    before = paths.to_h { |path| [path, File.binread(File.join(@app, path))] }
    id = upgrade_digest(target)
    rails('generate', 'foundry:skills', '--upgrade', "--target=#{target}", "--apply=#{id}", '--pretend')
    before.each { |path, content| assert_equal content, File.binread(File.join(@app, path)) }
    apply_and_review(target, id)
    assert_includes File.read(File.join(@app, @upgrade_ai)), 'including packages without foundry.yml'
    verify_upgraded_helper
    rails('generate', 'foundry:skills', "--target=#{target}")
    before.except(@upgrade_receipt, @upgrade_ai, "#{@upgrade_base}/scripts/verify.rb").each do |path, content|
      assert_equal content, File.binread(File.join(@app, path))
    end
    rails('generate', 'foundry:skills', '--upgrade', "--target=#{target}", "--rollback=#{id}")
    before.each { |path, content| assert_equal content, File.binread(File.join(@app, path)) }
    next_id = upgrade_digest(target)
    refute_equal id, next_id
    apply_and_review(target, next_id)
    assert_equal 8, Dir[File.join(@app, ".#{target}/skills/foundry-*/SKILL.md")].size
  end

  def prepare_prior_catalog(pack_root)
    script = "#{@upgrade_base}/scripts/verify.rb"
    skill = "#{@upgrade_base}/SKILL.md"
    receipt = JSON.parse(File.binread(File.join(@app, @upgrade_receipt)))
    { script => '# Previous helper fixture', skill => 'Previous guidance fixture',
      @upgrade_ai => 'Previous AI guidance fixture' }.each do |path, content|
      write("app/#{path}", content)
      receipt['files'][path] = Digest::SHA256.hexdigest(content)
    end
    write("app/#{@upgrade_receipt}", JSON.pretty_generate(receipt))
    write("app/#{skill}", 'Application-owned verification instructions')
    debt = "#{pack_root}/assistance/package_todo.yml"
    write("app/#{debt}", "# Accepted debt\n{}\n")
    write('app/AGENTS.md', 'Application-owned project instructions')
    write('app/.agents/skills/custom/SKILL.md', 'Unrelated local guidance')
    config = YAML.safe_load_file(File.join(@app, 'config/foundry.yml'))
    config['workflow']['specs'] = pack_root == 'packs' ? 'none' : 'openspec'
    write('app/config/foundry.yml', YAML.dump(config))
    [script, skill, @upgrade_ai, @upgrade_receipt, debt, 'AGENTS.md', '.agents/skills/custom/SKILL.md',
     'config/foundry.yml']
  end

  def upgrade_digest(target)
    output = rails('generate', 'foundry:skills', '--upgrade', "--target=#{target}")
    output.match(/Review digest: ([0-9a-f]{64})/)[1]
  end

  def apply_and_review(target, id)
    output, error, status = command(RbConfig.ruby, 'bin/rails', 'generate', 'foundry:skills', '--upgrade',
                                    "--target=#{target}", "--apply=#{id}")
    refute status.success?, output
    assert_includes error, 'review pending'
    _out, failure, generation = command(RbConfig.ruby, 'bin/rails', 'generate', 'foundry:skills', "--target=#{target}")
    refute generation.success?
    assert_includes failure, 'Upgrade pending'
    path = ".foundry/skill-upgrades/#{target}/#{id}/decisions.json"
    decisions = JSON.parse(File.binread(File.join(@app, path)))
    decisions['files'].each_value { |entry| entry['decision'] = 'keep_local' }
    write("app/#{path}", JSON.pretty_generate(decisions))
    rails('generate', 'foundry:skills', '--upgrade', "--target=#{target}", "--resolve=#{path}")
  end

  def verify_upgraded_helper
    Dir[File.join(ArchiveAcceptance::SOURCE, 'test_packaging/fixtures/verification/*.rb')].each do |path|
      name = File.basename(path).sub(/\A(caller|browser)\.rb\z/, '\1_test.rb')
      write("app/test/verification_fixture/#{name}", File.binread(path))
    end
    arguments = [RbConfig.ruby, "#{@upgrade_base}/scripts/verify.rb", '--baseline',
                 'test/verification_fixture/caller_test.rb', '--caller', 'test/verification_fixture/caller_test.rb',
                 '--realtime', '--browser', 'test/verification_fixture/browser_test.rb', '--timeout', '120']
    output = assert_command(*arguments)
    assert_includes output, 'Verified browser: 1 tests'
    %w[caller browser].each do |fault|
      output, error, status = command(*arguments, extra_env: { 'FOUNDRY_FIXTURE_FAULT' => fault })
      refute status.success?, output
      assert_match(/(?:Failure|Error):/, output)
      assert_includes error, "#{fault == 'caller' ? 'baseline' : 'browser'}: command failed"
    end
  ensure
    FileUtils.rm_rf(File.join(@app, 'test/verification_fixture'))
  end
end
