# frozen_string_literal: true

require_relative '../test/test_helper'
require_relative 'archive_helper'
require_relative 'support/behavioral_controls'

class FirstFeatureTest < FoundryTest
  include ArchiveAcceptance
  include BehavioralControls

  def test_installed_tutorial_with_default_roots
    verify_tutorial('packs')
  end

  def test_installed_tutorial_with_custom_roots
    verify_tutorial('components')
  end

  private

  def verify_tutorial(pack_root)
    prepare_tutorial
    installed = File.join(@gem_home, 'gems', "rails_ai_foundry-#{RailsAIFoundry::VERSION}")
    guide = File.read(File.join(installed, 'docs/first-feature.md'))
    snippets = guide.scan(/^```(\w+)(?: file=(\S+))? phase=(\w+)\n(.*?)^```/m)
    refute_empty snippets
    snippets.each do |language, path, phase, body|
      body = body.gsub('packs/', "#{pack_root}/")
      if path
        write("app/#{path.gsub('packs/', "#{pack_root}/")}", body)
      else
        assert_equal 'sh', language
        replay_commands(body, phase)
      end
    end
    verify_persistence_and_dependencies(pack_root)
    verify_behavioral_controls(pack_root)
  end

  def prepare_tutorial
    build_archive
    prepare_host
    File.open(File.join(@app, 'Gemfile'), 'a') { |file| file.puts "gem 'packs-rails', '~> 0.1.0'" }
    application = File.read(File.join(@app, 'config/application.rb'))
    write('app/config/application.rb',
          application.sub("require 'rails_ai_foundry'", "require 'packs-rails'\nrequire 'rails_ai_foundry'"))
    assert_command(RbConfig.ruby, '-S', 'gem', 'install', @archive, '--local', '--ignore-dependencies',
                   '--no-document', '--install-dir', @gem_home)
    assert_command(RbConfig.ruby, '-S', 'bundle', 'install', '--local')
    assert_provenance
    assert_command(RbConfig.ruby, File.join(@gem_home, 'bin/foundry'), 'setup', '--specs=none')
  end

  def replay_commands(body, phase)
    body.lines.map(&:strip).reject(&:empty?).each do |line|
      output, error, status = command(*Shellwords.split(line))
      if phase == 'violation'
        refute status.success?, "#{line}\n#{output}\n#{error}"
        assert_includes output, 'Privacy violation'
        assert_includes output, 'Customers::Customer'
      else
        assert status.success?, "#{line}\n#{output}\n#{error}"
      end
    end
  end

  def verify_persistence_and_dependencies(pack_root)
    rails('runner', <<~RUBY)
      raise 'restart persistence failed' unless Billing::Invoice.where(amount_cents: 2300).count == 1
      customer = Customers::Customer.find_by!(name: 'Restart proof')
      raise 'public lookup failed' unless Billing::PrivateProbe.new.call(customer.id).fetch(:name) == 'Restart proof'
      begin
        Billing::Invoice.insert_all!([{ customer_id: customer.id, amount_cents: -1 }])
        raise 'database constraint missing'
      rescue ActiveRecord::StatementInvalid
      end
    RUBY
    config = YAML.safe_load_file(File.join(@app, pack_root, 'billing/package.yml'))
    assert_includes config.fetch('dependencies'), "#{pack_root}/customers"
    assert config.fetch('enforce_privacy')
    assert_empty Dir[File.join(@app, '**/package_todo.yml')]
  end
end
