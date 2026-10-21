# frozen_string_literal: true

require_relative 'prerequisites'
require_relative 'local_overrides'

module BenchmarkSuite
  class Images
    def self.build(root)
      root = Pathname(root).realpath
      raise Failure, 'Images already resolved' if root.join('images.json').exist?

      prepare_prerequisite_base(root)
      images = Lemans::Config.load_file(root).tasks.map(&:environment_image).uniq(&:name)
      records = images.to_h { |image| [image.name, build_image(image)] }
      Support.json(root.join('images.json'), records)
      records
    end

    def self.prepare_prerequisite_base(root)
      return unless [Prerequisites::TASK, LocalOverrides::SAAS].any? { |name| root.join('tasks', name).directory? }

      image = Lemans::Config::ImageSpec.dockerfile(root.join('docker/fizzy/Dockerfile'), slug: 'fizzy')
      build_image(image)
    end

    def self.build_image(image)
      Support.docker('build', '--progress', 'plain', '--tag', image.name, image.context_dir.to_s) if image.built?
      result = Support.docker('image', 'inspect', image.name)
      details = JSON.parse(result.fetch('output')).first
      { 'id' => details.fetch('Id'), 'architecture' => details.fetch('Architecture'),
        'repo_digests' => details['RepoDigests'] }
    end
  end
end
