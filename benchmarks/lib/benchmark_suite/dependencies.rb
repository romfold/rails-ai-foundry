# frozen_string_literal: true

require_relative 'evidence'

module BenchmarkSuite
  class Dependencies
    def self.capture(workspace, output)
      root = Pathname(workspace).realpath
      images = JSON.parse(root.join('images.json').read)
      evidence = Evidence.new(output)
      tasks = Lemans::Config.load_file(root).tasks.uniq { |task| task.environment_image.name }
      evidence.json('dependencies.json', records(tasks, images))
    end

    def self.records(tasks, images)
      tasks.to_h do |task|
        image = images.fetch(task.environment_image.name).fetch('id')
        [image, inspect_image(image, task.environment.workdir)]
      end
    end

    def self.inspect_image(image, workdir)
      script = <<~RUBY
        require 'json'
        require 'digest'
        lockfile = File.basename(ENV.fetch('BUNDLE_GEMFILE', 'Gemfile')) + '.lock'
        lock = File.file?(lockfile) ? File.binread(lockfile) : nil
        puts JSON.generate(ruby: RUBY_DESCRIPTION, lockfile: lockfile, lock: lock,
          lock_sha256: lock && Digest::SHA256.hexdigest(lock),
          gems: Gem::Specification.map { |gem| [gem.name, gem.version.to_s, gem.platform.to_s] }.sort)
      RUBY
      result = Support.docker('run', '--rm', '--network', 'none', '--read-only', '--cap-drop', 'ALL',
                              '--security-opt', 'no-new-privileges', '--workdir', workdir,
                              '--entrypoint', 'ruby', image, '-e', script)
      JSON.parse(result.fetch('output').lines.last)
    end
  end
end
