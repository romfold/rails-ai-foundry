# frozen_string_literal: true

module DeliveryControls
  private

  def verify_delivery_controls
    FileUtils.rm_rf(File.join(@app, 'public/assets'))
    caller = "#{@pack_root}/search/test/requests/search_test.rb"
    browser = "#{@pack_root}/search/test/system/search_test.rb"
    fault('config/routes.rb', "Rails.application.routes.draw {}\n", 'searches_path', caller)
    helper = "#{@pack_root}/search/app/helpers/search_experience/searches_helper.rb"
    fault(helper, 'module SearchExperience::SearchesHelper; end', 'result_label', caller)
    view = "#{@pack_root}/search/app/views/search_experience/searches/index.html.erb"
    fault(view, '<% render "searches/missing_results" %>', 'Missing partial', caller)
    controller = "#{@pack_root}/search/app/controllers/search_experience/searches_controller.rb"
    body = File.read(File.join(@app, controller))
    fault(controller, body.sub('Document.where(owner: session[:viewer])', 'Document.all'), 'Failure:', caller)
    importmap = File.read(File.join(@app, 'config/importmap.rb'))
    fault('config/importmap.rb', importmap.lines.reject { |line| line.include?('pin_all_from') }.join,
          'Ready', browser)
    verify_private_access
    verify_omitted_file
    verify_equivalent_routes
    assert_includes assert_command(RbConfig.ruby, 'bin/verify-feature'), 'Selected feature verification passed'
  end

  def fault(path, replacement, evidence, selection)
    original = File.binread(File.join(@app, path))
    write("app/#{path}", replacement)
    output, error, status = command(RbConfig.ruby, 'bin/rails', 'test', selection,
                                    extra_env: { 'RAILS_ENV' => 'test' })
    refute status.success?, "Fault not rejected: #{path}"
    assert_includes output + error, evidence
    write("app/#{path}", original)
    assert_command(RbConfig.ruby, 'bin/rails', 'test', selection, extra_env: { 'RAILS_ENV' => 'test' })
  ensure
    write("app/#{path}", original) if original
  end

  def verify_private_access
    write('app/app/models/private_probe.rb', 'class PrivateProbe; TARGET = SearchExperience::SearchesController; end')
    output, error, status = command(RbConfig.ruby, 'bin/packwerk', 'check', extra_env: { 'RAILS_ENV' => 'test' })
    refute status.success?, output
    assert_includes output + error, 'Privacy violation'
  ensure
    FileUtils.rm_f(File.join(@app, 'app/models/private_probe.rb'))
  end

  def verify_omitted_file
    path = "#{@pack_root}/search/test/omitted_test.rb"
    write("app/#{path}", 'require "test_helper"')
    runner = 'bin/rails'
    original = File.binread(File.join(@app, runner))
    # Simulate a runner silently discarding one inventoried baseline file.
    omit = "ARGV.reject! { |argument| argument.delete_prefix('./') == '#{path}' }\n"
    write("app/#{runner}", original.sub("require 'rails/commands'", "#{omit}require 'rails/commands'"))
    output, error, status = command(RbConfig.ruby, 'bin/verify-feature')
    refute status.success?, output
    assert_includes error, "planned files were not loaded: #{path}"
  ensure
    write("app/#{runner}", original) if original
    FileUtils.rm_f(File.join(@app, path))
  end

  def verify_equivalent_routes
    routes = File.read(File.join(@app, 'config/routes.rb'))
    write("app/#{@pack_root}/search/config/routes/search.rb",
          "resources :searches, only: %i[index create], controller: 'search_experience/searches'\n")
    write('app/config/routes.rb', routes.sub(/  resources :searches.*$/, '  draw :search'))
    assert_includes assert_command(RbConfig.ruby, 'bin/verify-feature'), 'Selected feature verification passed'
    assert_command(RbConfig.ruby, 'bin/packwerk', 'check', extra_env: { 'RAILS_ENV' => 'test' })
  end
end
