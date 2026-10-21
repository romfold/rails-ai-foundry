# frozen_string_literal: true

module SkillUpgradeHelpers
  private

  def install
    RailsAIFoundry::Generation::SkillInstaller.new(@root, target: @target).call
  end

  def command
    RailsAIFoundry::Generation::SkillUpgrade::Command.new(@root, target: @target)
  end

  def incoming(path)
    RailsAIFoundry::Generation::SkillInstaller.new(@root, target: @target).files.fetch(path)
  end

  def incoming_receipt
    incoming(@receipt)
  end

  def digest
    command.call.first.delete_prefix('Review digest: ')
  end

  def read(path)
    File.binread(File.join(@root, path))
  end

  def installed
    snapshot.reject { |path, _| path.start_with?('.foundry/skill-upgrades/') }
  end

  def old(path, base, local: base)
    data = JSON.parse(read(@receipt))
    data['files'][path] = Digest::SHA256.hexdigest(base)
    write(@receipt, JSON.pretty_generate(data))
    write(path, local)
  end

  def customize(path)
    write(path, "#{read(path)}\nLocal instructions")
  end

  def remove_owned(path)
    data = JSON.parse(read(@receipt))
    data['files'].delete(path)
    write(@receipt, JSON.generate(data))
    File.unlink(File.join(@root, path))
  end

  def add_retired(name, customized:)
    path = ".#{@target}/skills/foundry-verify/#{name}"
    old(path, 'retired', local: customized ? 'custom retired' : 'retired')
    path
  end

  def directory(id)
    ".foundry/skill-upgrades/#{@target}/#{id}"
  end

  def state(id)
    JSON.parse(read("#{directory(id)}/state.json"))
  end

  def decisions(id, choices)
    files = choices.to_h { |path, choice| [path, { 'decision' => choice, 'sha256' => Digest::SHA256.hexdigest(read(path)) }] }
    write("#{directory(id)}/decisions.json", JSON.generate('session' => id, 'files' => files))
  end

  def with_incoming_change(path, content, &block)
    instance = RailsAIFoundry::Generation::SkillInstaller.new(@root, target: @target)
    files = instance.files.merge(path => content)
    hashes = files.except(@receipt).transform_values { |value| Digest::SHA256.hexdigest(value) }
    files[@receipt] = JSON.pretty_generate('version' => '1.0.0', 'files' => hashes)
    instance.stub(:files, files) do
      RailsAIFoundry::Generation::SkillInstaller.stub(:new, ->(*) { instance }, &block)
    end
  end
end
