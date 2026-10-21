# frozen_string_literal: true

require_relative '../test/test_helper'
require_relative '../test_packaging/archive_helper'
require_relative 'support/controls'
require_relative 'support/upgrades'

class InstalledDeliveryTest < FoundryTest
  include ArchiveAcceptance
  include DeliveryControls
  include DeliveryUpgrades

  %w[packs components].each do |root|
    define_method("test_delivery_extraction_#{root}") { replay(root) }
  end

  private

  def replay(root)
    @pack_root = root
    build_archive
    prepare_host
    prepare_locked_bundle
    write('network_guard.rb', '') # Local browser and SQLite; no application provider or CDN.
    assert_command(RbConfig.ruby, '-S', 'gem', 'install', @archive, '--local', '--ignore-dependencies',
                   '--no-document', '--install-dir', @gem_home)
    installed = File.join(@gem_home, 'gems', "rails_ai_foundry-#{RailsAIFoundry::VERSION}")
    guide = File.read(File.join(installed, 'docs/delivery-pack-extraction.md'))
    snippets = guide.scan(/^```(\w+)(?: file=(\S+))? phase=(\w+)\n(.*?)^```/m)
    assert_operator snippets.size, :>, 30
    snippets.each { |snippet| replay_snippet(*snippet) }
    verify_frozen_state
    verify_package_intent
    verify_production
    verify_delivery_controls
    verify_delivery_upgrades
  end

  def prepare_locked_bundle
    # Reuse the lane's exact resolution, replacing only the checkout source with the built gem.
    lock = File.read(File.join(__dir__, 'bundle/Gemfile.lock'))
    path, rest = lock.split("\n\n", 2)
    specification = path.split("  specs:\n", 2).last
    lock = rest.sub(/^    railties \(/, "#{specification}\n    railties (")
               .sub('rails_ai_foundry!', "rails_ai_foundry (= #{RailsAIFoundry::VERSION})")
    write('app/Gemfile.lock', lock)
    write('app/.bundle/config', "BUNDLE_LOCKFILE_CHECKSUMS: false\nBUNDLE_FROZEN: true\n")
  end

  def replay_snippet(language, path, phase, body)
    body = body.gsub('packs/', "#{@pack_root}/")
    if phase == 'extract' && !@before
      @before = protected_state
      @data = data_snapshot
    end
    if path
      write("app/#{path.gsub('packs/', "#{@pack_root}/")}", body)
    else
      assert_equal 'sh', language
      body.lines.map(&:strip).reject(&:empty?).each { |line| assert_command(*Shellwords.split(line)) }
    end
  end

  def protected_state
    %w[Gemfile Gemfile.lock db/schema.rb app/models/document.rb app/models/search.rb
       app/models/application_record.rb app/controllers/application_controller.rb
       app/controllers/demo_sessions_controller.rb app/views/layouts/application.html.erb
       test/test_helper.rb test/application_system_test_case.rb].to_h do |path|
      [path, File.binread(File.join(@app, path))]
    end
  end

  def data_snapshot
    rails('runner', 'puts({ documents: Document.order(:id).map(&:attributes), ' \
                    'searches: Search.order(:id).map(&:attributes) }.to_json)').strip
  end

  def verify_frozen_state
    assert_equal @before, protected_state
    assert_equal @data, data_snapshot
    assert_equal 2, JSON.parse(@data).fetch('documents').size
    assert_equal 1, JSON.parse(@data).fetch('searches').size
    @before = nil
    assert_provenance
  end

  def verify_production
    environment = { 'RAILS_ENV' => 'production', 'BUNDLE_WITHOUT' => 'development:test' }
    output = rails('runner', <<~RUBY, extra_env: environment)
      Rails.application.eager_load!
      raise 'Foundry loaded' if Gem.loaded_specs.key?('rails_ai_foundry')
      raise 'Delivery missing' unless SearchExperience::SearchesController < ApplicationController
      client = Rack::MockRequest.new(Rails.application)
      raise 'Login unavailable' unless client.get('/demo_session/new').status == 200
      raise 'Authentication bypass' unless client.get('/searches').status == 302
      manifest = JSON.parse(File.read(Rails.root.join('public/assets/.manifest.json')))
      asset = manifest.fetch('controllers/search_results_controller.js').fetch('digested_path')
      response = client.get("/assets/\#{asset}")
      raise 'Compiled feature asset unavailable' unless response.status == 200 && response.body.include?('reveal()')
      puts 'Native production loading passed'
    RUBY
    assert_includes output, 'Native production loading passed'
  end

  def verify_package_intent
    report = JSON.parse(assert_command('bundle', 'exec', 'foundry', 'check', '--sources', '--format=json'))
    assert_equal [{ 'path' => "#{@pack_root}/search", 'configuration' => "#{@pack_root}/search/foundry.yml",
                    'namespace' => 'SearchExperience', 'profile' => 'rails_native',
                    'patterns' => { 'events' => 'none', 'cqrs' => 'none' } }], report.fetch('contexts')
    package = YAML.safe_load_file(File.join(@app, @pack_root, 'search/package.yml'))
    assert_equal ['.'], package.fetch('dependencies')
    assert package.fetch('enforce_dependencies')
    assert package.fetch('enforce_privacy')
  end
end
