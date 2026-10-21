# frozen_string_literal: true

module FoundrySkillVerification
  class PackageBaseline
    def initialize(selection)
      @selection = selection
    end

    def command(output)
      options = @selection.phases.slice('baseline', 'browser').merge('framework' => @selection.framework)
      [RbConfig.ruby, '-rbundler/setup', File.join(__dir__, 'package_discovery.rb'), JSON.generate(options), output]
    end

    def files(output)
      inventory = JSON.parse(File.read(output))
      raise Failure, 'Malformed package discovery evidence; no test phases executed.' unless valid?(inventory)

      print_inventory(inventory)
      raise Failure, 'Package discovery found no non-system baseline tests.' if inventory['files'].empty?

      inventory['files']
    rescue JSON::ParserError, Errno::ENOENT
      raise Failure, 'Missing or malformed package discovery evidence; no test phases executed.'
    end

    private

    def print_inventory(inventory)
      inventory['origins'].each { |path, origin| puts "Baseline #{origin}: #{path}" }
      inventory['deferred'].each { |path| puts "Deferred browser (select --browser): #{path}" }
      inventory['untested_packages'].each { |pack| puts "Package without baseline tests: #{pack}" }
    end

    def valid?(data)
      return false unless data.is_a?(Hash) && data['origins'].is_a?(Hash)
      return false unless %w[files deferred untested_packages].all? { |key| paths?(data[key], key) }

      data['origins'].keys.sort == data['files'] && data['origins'].values.all?(String)
    end

    def paths?(paths, kind)
      paths.is_a?(Array) && paths == paths.uniq.sort && paths.all? do |path|
        path.is_a?(String) && local?(path, directory: kind == 'untested_packages')
      end
    rescue ArgumentError
      false
    end

    def local?(path, directory:)
      return false if Pathname(path).absolute?

      target = File.join(@selection.root, path)
      real = File.realpath(target)
      return false unless real == @selection.root || real.start_with?("#{@selection.root}/")

      directory ? File.directory?(real) : File.file?(real)
    rescue SystemCallError
      false
    end
  end
end
