# frozen_string_literal: true

require 'rubygems/package'
require 'json'
require 'bundler'
require 'shellwords'

module ArchiveAcceptance
  SOURCE = File.expand_path('..', __dir__)

  private

  def build_archive
    spec = Gem::Specification.load(File.join(SOURCE, 'rails_ai_foundry.gemspec'))
    files = spec.files + ['rails_ai_foundry.gemspec']
    files.each do |file|
      write("build/#{file}", File.binread(File.join(SOURCE, file)))
      File.chmod(File.stat(File.join(SOURCE, file)).mode & 0o777, File.join(@root, 'build', file))
    end
    @archive = Dir.chdir(File.join(@root, 'build')) do
      built = Gem::Package.build(Gem::Specification.load('rails_ai_foundry.gemspec'))
      File.expand_path(built)
    end
    contents = Gem::Package.new(@archive).contents
    assert_includes contents, 'docs/core-workflow.md'
    assert_equal(8, contents.count { |file| file.start_with?('schemas/') && file.end_with?('-v1.json') })
    assert_includes contents, 'docs/stable-contracts.md'
    assert_equal(8, contents.count { |file| file.start_with?('skills/') && file.end_with?('/SKILL.md') })
    assert_empty contents.grep(%r{\A(?:examples|test|\.agents|openspec)/})
    assert_empty contents.grep(%r{\Alib/rails_ai_foundry/(?:architecture|ai|events|promotion|plan|setup)/})
    assert_empty contents.grep(%r{\Alib/rails_ai_foundry/(?:runtime|composition|package_loading|unit_of_work)\.rb\z})
    assert_empty contents.grep(%r{\Alib/generators/foundry/(?:install|setup|package)/})
    assert_equal File.binread(File.join(SOURCE, 'LICENSE')), File.binread(File.join(@root, 'build/LICENSE'))
  end

  def prepare_host
    @app = File.join(@root, 'app')
    @gem_home = File.join(@root, 'gems')
    FileUtils.mkdir_p(@app)
    FileUtils.cp_r(Dir[File.join(SOURCE, 'test/runtime_host/*')], @app)
    # Offline fixture resolution cannot fetch checksum metadata for cached gems.
    # Keep Bundler 4 from generating empty entries that fail frozen boundary checks.
    write('app/.bundle/config', "BUNDLE_LOCKFILE_CHECKSUMS: false\n")
    write('app/Gemfile', <<~RUBY)
      source 'https://rubygems.org'
      gem 'rails_ai_foundry', '#{RailsAIFoundry::VERSION}'
      gem 'railties', '#{Gem.loaded_specs.fetch('railties').version}'
      gem 'minitest', '#{Gem.loaded_specs.fetch('minitest').version}'
      gem 'activerecord', '#{Gem.loaded_specs.fetch('activerecord').version}'
      gem 'sqlite3', '#{Gem.loaded_specs.fetch('sqlite3').version}'
    RUBY
    application = File.read(File.join(@app, 'config/application.rb'))
    write('app/config/application.rb',
          application.sub("require 'rails'", "require 'rails'\nrequire 'active_record/railtie'"))
    write('app/config/database.yml', "development:\n  adapter: sqlite3\n  database: tmp/development.sqlite3\n" \
                                     "test:\n  adapter: sqlite3\n  database: tmp/test.sqlite3\n" \
                                     "production:\n  adapter: sqlite3\n  database: tmp/development.sqlite3\n")
    prepare_network_guard
  end

  def prepare_network_guard
    write('network_guard.rb', <<~RUBY)
      require 'socket'
      module FoundryOfflineSocket
        def connect(*)
          raise 'External requests are blocked in archive acceptance'
        end
        alias_method :connect_nonblock, :connect
      end
      Socket.prepend(FoundryOfflineSocket)
      UDPSocket.prepend(FoundryOfflineSocket)
      Socket.define_singleton_method(:tcp) { |*| raise 'External requests are blocked in archive acceptance' }
      TCPSocket.define_singleton_method(:new) { |*| raise 'External requests are blocked in archive acceptance' }
      TCPSocket.define_singleton_method(:open) { |*| raise 'External requests are blocked in archive acceptance' }
    RUBY
  end

  def command(*arguments, extra_env: {})
    env = { 'GEM_HOME' => @gem_home, 'GEM_PATH' => ([@gem_home] + Gem.path).join(File::PATH_SEPARATOR),
            'BUNDLE_GEMFILE' => File.join(@app, 'Gemfile'), 'FOUNDRY_AUTOLOAD' => '0',
            'RAILS_ENV' => 'development', 'RUBYLIB' => nil, 'BUNDLE_VERSION' => Bundler::VERSION,
            'RUBYOPT' => "-r#{File.join(@root, 'network_guard.rb')}" }
    puts "[archive acceptance] #{arguments.shelljoin}"
    result = Bundler.with_unbundled_env do
      Open3.capture3(env.merge(extra_env), *arguments, chdir: @app)
    end
    # CLI reports are UTF-8 even when this acceptance process uses LC_ALL=C.
    result.take(2).each { |text| text.force_encoding(Encoding::UTF_8) }
    puts result[0] unless result[0].empty?
    warn result[1] unless result[1].empty?
    result
  end

  def assert_command(*arguments, **options)
    output, error, status = command(*arguments, **options)
    assert status.success?, "#{output}\n#{error}"
    output
  end

  def rails(*arguments, **options)
    assert_command(RbConfig.ruby, 'bin/rails', *arguments, **options)
  end

  def assert_provenance
    code = "require 'bundler/setup'; require 'rails_ai_foundry'; " \
           "puts Gem.loaded_specs.fetch('rails_ai_foundry').full_gem_path; raise 'AI loaded' if defined?(RubyLLM)"
    output = assert_command(RbConfig.ruby, '-e', code)
    expected = File.join(@gem_home, 'gems', "rails_ai_foundry-#{RailsAIFoundry::VERSION}")
    assert_equal File.realpath(expected), File.realpath(output.strip)
    version = assert_command(RbConfig.ruby, File.join(@gem_home, 'bin/foundry'), '--version')
    assert_equal RailsAIFoundry::VERSION, version.strip
    inventory = JSON.parse(assert_command(RbConfig.ruby, File.join(@gem_home, 'bin/foundry'), 'contracts'))
    assert_equal 1, inventory['report_schema']
    assert_equal 8, inventory.fetch('schemas').size
    inventory.fetch('schemas').each_value do |path|
      assert File.realpath(path).start_with?("#{File.realpath(expected)}/schemas/"), path
      assert File.file?(path), path
    end
  end
end
