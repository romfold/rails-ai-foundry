# frozen_string_literal: true

require_relative 'executable_verification'

module BehavioralControls
  include ExecutableVerification

  private

  def verify_behavioral_controls(pack_root)
    verify_installed_guidance
    verify_context_location(pack_root)
    verify_executable_guidance(pack_root)
    controller = "app/#{pack_root}/billing/app/controllers/billing/invoices_controller.rb"
    original = File.read(File.join(@root, controller))
    relocated = "app/#{pack_root}/billing/app/queries/billing/invoice_lookup.rb"
    write(relocated, 'module Billing; class InvoiceLookup; def self.call(id); Invoice.find(id); end; end; end')
    ['Invoice.find(params[:id])', 'InvoiceLookup.call(params[:id])', 'lookup(params[:id])'].each do |expression|
      write(controller, controller_source(expression))
      rails('test', "#{pack_root}/billing/test/invoices_delivery_test.rb")
    end
    write(controller, controller_source('Invoice.new(id: params[:id], amount_cents: 0)'))
    assert_command(RbConfig.ruby, File.join(@gem_home, 'bin/foundry'), 'check', '--sources', '--boundaries')
    output, error, status = command(RbConfig.ruby, 'bin/rails', 'test',
                                    "#{pack_root}/billing/test/invoices_delivery_test.rb")
    refute status.success?, "Faulty endpoint passed: #{output}\n#{error}"
    assert_match(/1 failures, 0 errors/, output)
  ensure
    write(controller, original) if original
  end

  def controller_source(expression)
    <<~RUBY
          module Billing
            class InvoicesController < ApplicationController
              def show
                @invoice = #{expression}
              end
      private
              def lookup(id)
                Invoice.find(id)
              end
            end
          end
    RUBY
  end

  def verify_installed_guidance
    rails('generate', 'foundry:skills')
    reference = '.agents/skills/foundry-verify/references/behavioral-recovery.md'
    installed = File.join(@gem_home, 'gems', "rails_ai_foundry-#{RailsAIFoundry::VERSION}")
    %w[foundry-add-feature foundry-event-workflow foundry-verify foundry-add-package
       foundry-adopt-existing-app].each do |skill|
      %w[SKILL.md references/behavioral-recovery.md references/packs.md references/reviewed-ai-work.md].each do |path|
        source = path == 'SKILL.md' ? "#{skill}/#{path}" : path
        assert_equal File.binread(File.join(installed, 'skills', source)),
                     File.binread(File.join(@app, '.agents/skills', skill, path))
      end
    end
    assert_equal File.binread(File.join(installed, 'skills/references/behavioral-recovery.md')),
                 File.binread(File.join(@app, reference))
    verify_installed_scripts(installed)
    verify_custom_guidance(reference)
  end

  def verify_custom_guidance(reference)
    write("app/#{reference}", 'Application-owned recovery procedure')
    custom_skill = '.agents/skills/foundry-add-feature/SKILL.md'
    write("app/#{custom_skill}", 'Application-owned feature workflow')
    reviewed_reference = '.agents/skills/foundry-verify/references/reviewed-ai-work.md'
    write("app/#{reviewed_reference}", 'Application-owned approval policy')
    receipt = File.binread(File.join(@app, '.foundry/skills/agents.json'))
    rails('generate', 'foundry:skills')
    assert_equal 'Application-owned recovery procedure', File.binread(File.join(@app, reference))
    assert_equal 'Application-owned feature workflow', File.binread(File.join(@app, custom_skill))
    assert_equal 'Application-owned approval policy', File.binread(File.join(@app, reviewed_reference))
    assert_equal receipt, File.binread(File.join(@app, '.foundry/skills/agents.json'))
    assert_equal 8, Dir[File.join(@app, '.agents/skills/*/SKILL.md')].size
    assert_equal 'none', YAML.safe_load_file(File.join(@app, 'config/foundry.yml')).dig('workflow', 'specs')
  end

  def verify_context_location(pack_root)
    foundry = File.join(@gem_home, 'bin/foundry')
    output, error, status = command(RbConfig.ruby, foundry, 'check', '--sources', '--format=json')
    assert status.success?, error
    context = JSON.parse(output).fetch('contexts').find { |item| item['path'] == "#{pack_root}/billing" }
    assert_equal 'Billing', context.fetch('namespace')
    intent = YAML.safe_load_file(File.join(@app, pack_root, 'billing/foundry.yml'))
    assert_equal intent.fetch('profile'), context.fetch('profile')
    verify_misplaced_sidecar(foundry, pack_root)
  end

  def verify_misplaced_sidecar(foundry, pack_root)
    misplaced = "app/#{pack_root}/billing/config/foundry.yml"
    debt = "app/#{pack_root}/billing/package_todo.yml"
    write(debt, "# Previously reviewed debt must not be regenerated\n{}\n")
    write(misplaced, "profile: modular\n")
    before = snapshot
    _output, error, status = command(RbConfig.ruby, foundry, 'check', '--sources')
    refute status.success?
    assert_includes error, "#{pack_root}/billing/config/foundry.yml"
    assert_includes error, "Use #{pack_root}/billing/foundry.yml"
    assert_equal before, snapshot
  ensure
    [misplaced, debt].compact.each do |path|
      File.unlink(File.join(@root, path)) if File.file?(File.join(@root, path))
    end
  end
end
