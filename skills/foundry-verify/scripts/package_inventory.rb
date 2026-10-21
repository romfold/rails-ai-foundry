# frozen_string_literal: true

require 'find'
require 'json'
require 'pathname'
require 'yaml'

module FoundrySkillVerification
  class DiscoveryFailure < StandardError; end

  class PackageInventory
    EXCLUDED = %w[system fixtures dummy support node_modules].freeze

    def initialize(options)
      @root = File.realpath(Dir.pwd)
      @framework = options.fetch('framework')
      @extra = options.fetch('baseline')
      @browser = options.fetch('browser')
      @directory, @suffix = @framework == 'rspec' ? %w[spec _spec.rb] : %w[test _test.rb]
      @files = {}
      @deferred = []
    end

    def call
      validate_settings
      validate_environment
      discover_packages
      ['.', *@packages].uniq.each { |pack| scan(File.join(pack, @directory)) }
      @extra.each { |path| add_explicit(path) }
      result
    end

    private

    def result
      { 'files' => @files.keys.sort, 'origins' => @files.sort.to_h, 'deferred' => @deferred.uniq.sort,
        'untested_packages' => @packages.reject { |pack| @files.keys.any? { |path| owner(path) == pack } } }
    end

    def validate_settings
      config = package_settings
      raise DiscoveryFailure, 'packs.yml must contain a mapping.' unless config.is_a?(Hash)

      paths = config['pack_paths']
      return unless paths && (!paths.is_a?(Array) || !paths.all? { |path| safe_glob?(path) })

      raise DiscoveryFailure, 'packs.yml pack_paths must contain application-relative glob strings.'
    end

    def package_settings
      return {} unless File.exist?('packs.yml')

      relative('packs.yml')
      YAML.safe_load_file('packs.yml')
    end

    def validate_environment
      return unless %w[DEFAULT_TEST DEFAULT_TEST_EXCLUDE TESTOPTS SPEC_OPTS].any? { |key| !ENV[key].to_s.empty? }

      raise DiscoveryFailure, 'Custom test discovery/filter environment is unsupported with --include-pack-tests; ' \
                              'remove it or use the existing explicit verification workflow.'
    end

    def safe_glob?(path)
      path.is_a?(String) && !path.empty? && !Pathname(path).absolute? && !path.split('/').include?('..')
    end

    def discover_packages
      require 'packs-specification'
      @packages = Packs.all.map(&:name).uniq.sort
      @packages.each { |pack| validate_package(pack) }
    rescue LoadError
      raise DiscoveryFailure, 'Package verification requires packs-specification in the application locked bundle. ' \
                              'Add the dependency and run bundle install explicitly.'
    end

    def validate_package(pack)
      unless pack.is_a?(String) && safe_glob?(pack) && relative(pack) == Pathname(pack).cleanpath.to_s
        raise DiscoveryFailure, 'Ambiguous or unsafe package path; remove symbolic package aliases.'
      end

      relative(File.join(pack, 'package.yml'))
    end

    def relative(path)
      real = File.realpath(path)
      unless real == @root || real.start_with?("#{@root}/")
        raise DiscoveryFailure, 'Discovery requires application-local paths; a symbolic path escapes the application.'
      end

      Pathname(real).relative_path_from(Pathname(@root)).to_s
    end

    def scan(directory, explicit: false)
      return unless File.exist?(directory)

      relative(directory)
      Find.find(directory) do |path|
        Find.prune if !explicit && excluded_directory?(path, directory)
        validate_directory(path)
        next if File.directory?(path) || !path.end_with?(@suffix)

        classify(path, directory, explicit: explicit)
      end
    end

    def excluded_directory?(path, directory)
      File.directory?(path) && path != directory && (EXCLUDED - ['system']).include?(File.basename(path))
    end

    def classify(path, directory, explicit:)
      canonical = checked_file(path)
      parts = Pathname(path).relative_path_from(Pathname(directory)).each_filename.to_a
      if browser?(canonical) || parts.include?('system')
        raise DiscoveryFailure, 'System baseline paths require --browser instead.' if explicit

        @deferred << canonical
      elsif explicit || !parts.intersect?(EXCLUDED)
        add(canonical, explicit: explicit)
      end
    end

    def checked_file(path)
      canonical = relative(path)
      lexical = Pathname(File.expand_path(path)).relative_path_from(Pathname(@root)).to_s
      unless owner(lexical) == owner(canonical)
        raise DiscoveryFailure, 'Symbolic test file has ambiguous package ownership.'
      end

      canonical
    end

    def validate_directory(path)
      return unless File.symlink?(path)

      relative(path)
      return unless File.directory?(path)

      raise DiscoveryFailure, 'Symbolic test directories are ambiguous; use ordinary application-local test roots.'
    end

    def add_explicit(path)
      canonical = relative(path)
      raise DiscoveryFailure, 'System baseline paths require --browser instead.' if browser?(canonical)

      if File.directory?(path)
        scan(path, explicit: true)
      else
        add(canonical, explicit: true)
      end
    end

    def browser?(path)
      @browser.include?(path) || path.split('/').drop_while { |part| part != @directory }.include?('system')
    end

    def add(path, explicit: false)
      package = owner(path)
      origin = package == '.' ? 'root' : "package #{package}"
      @files[path] ||= explicit ? 'explicit' : origin
    end

    def owner(path)
      @packages.reject { |pack| pack == '.' }.sort_by { |pack| -pack.length }
               .find { |pack| path.start_with?("#{pack}/") } || '.'
    end
  end
end
