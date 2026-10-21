# frozen_string_literal: true

require 'bundler'
require 'fileutils'
require 'open3'
require 'rbconfig'
require 'shellwords'
require 'tmpdir'

class AdoptionVerification
  SOURCE = File.expand_path('..', __dir__)
  BASELINE = 'package_todo.yml'

  def run
    original = File.binread(File.join(SOURCE, BASELINE))
    Dir.mktmpdir('foundry-adoption-') do |copy|
      @copy = copy
      prepare_copy
      run_command('bundle', 'exec', 'foundry', 'check', '--boundaries')
      reject_new_debt(original)
      extract_legacy_endpoint
      run_command('bundle', 'exec', 'foundry', 'check', '--boundaries')
      run_command('bin/rails', 'db:prepare')
      run_command('bin/rails', 'test')
    end
    puts 'Adoption verified: accepted debt preserved, new debt rejected, extracted endpoint behavior unchanged.'
  ensure
    raise 'Checked-in debt changed during verification' unless original == File.binread(File.join(SOURCE, BASELINE))
  end

  private

  def prepare_copy
    %w[Gemfile Gemfile.lock Rakefile config app packs db test bin package.yml package_todo.yml
       packwerk.yml packs.yml].each { |path| FileUtils.cp_r(File.join(SOURCE, path), @copy) }
    gem_root = File.expand_path('../..', SOURCE)
    gemfile = File.join(@copy, 'Gemfile')
    File.write(gemfile, File.read(gemfile).sub("path: '../..'", "path: #{gem_root.inspect}"))
    lock = File.join(@copy, 'Gemfile.lock')
    File.write(lock, File.read(lock).sub('remote: ../..', "remote: #{gem_root}"))
    FileUtils.mkdir_p(File.join(@copy, 'storage'))
  end

  def reject_new_debt(original)
    extra = File.join(@copy, 'app/services/another_sales_report.rb')
    File.write(extra, "class AnotherSalesReport; MODEL = Billing::Invoice; end\n")
    output = run_command('bundle', 'exec', 'foundry', 'check', '--boundaries', success: false)
    unless %w[another_sales_report.rb Privacy Dependency].all? { |text| output.include?(text) }
      raise 'New dependency/privacy identity was not diagnosed'
    end
    raise 'Check changed accepted debt' unless original == File.binread(File.join(@copy, BASELINE))

    File.unlink(extra)
  end

  def extract_legacy_endpoint
    File.unlink(File.join(@copy, 'app/services/legacy_sales_report.rb'))
    File.unlink(File.join(@copy, 'app/controllers/legacy_reports_controller.rb'))
    routes = File.join(@copy, 'config/routes.rb')
    File.write(routes, File.read(routes).sub("to: 'legacy_reports#show'", "to: 'reports/summaries#show'"))
    # Explicitly retire the only reviewed identity, whose caller was removed.
    File.unlink(File.join(@copy, BASELINE))
  end

  def run_command(*argv, success: true)
    puts "[adoption verification] RAILS_ENV=test #{argv.shelljoin}"
    env = { 'BUNDLE_GEMFILE' => File.join(@copy, 'Gemfile'), 'BUNDLE_FROZEN' => 'true', 'RAILS_ENV' => 'test' }
    output, error, status = Bundler.with_unbundled_env { Open3.capture3(env, *argv, chdir: @copy) }
    puts output unless output.empty?
    warn error unless error.empty?
    raise "Unexpected exit status: #{status.exitstatus}" unless status.success? == success

    output + error
  end
end

AdoptionVerification.new.run
