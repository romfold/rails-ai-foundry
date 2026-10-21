# frozen_string_literal: true

require_relative 'support'

module BenchmarkSuite
  class Evidence
    def initialize(path, secrets: [])
      @root = Support.external_directory(path)
      @filter = Lemans::SecretsFilter.new(secrets)
    end

    def write(name, content)
      relative = Pathname(name)
      raise Failure, 'Evidence path escapes output' if relative.absolute? || relative.each_filename.include?('..')

      filtered = @filter.filter(Lemans::SecretsFilter.default.filter(content))
      path = @root.join(relative)
      path.dirname.mkpath
      File.open(path, File::WRONLY | File::CREAT | File::EXCL, 0o600) { |file| file.write(filtered) }
      { 'sha256' => Digest::SHA256.hexdigest(filtered), 'sanitized' => filtered != content }
    end

    def json(name, data)
      write(name, "#{JSON.pretty_generate(data)}\n")
    end
  end
end
