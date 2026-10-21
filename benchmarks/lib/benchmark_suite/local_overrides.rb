# frozen_string_literal: true

require_relative 'support'

module BenchmarkSuite
  module LocalOverrides
    SAAS = 'ft-saas-billing'

    module_function

    def prepare(root)
      original = preserve_dockerfile(root)
      base = Lemans::Config::ImageSpec.dockerfile(root.join('docker/fizzy/Dockerfile'), slug: 'fizzy')
      root.join('tasks', SAAS, 'environment/Dockerfile').write(original.sub(/^FROM .*$/, "FROM #{base.name}"))
      data = { 'verifier' => { 'timeout' => '30m' } }
      root.join('tasks', SAAS, 'bench.yml').write(data.to_yaml)
      record(root, base.name)
    end

    def preserve_dockerfile(root)
      original = root.join('tasks', SAAS, 'environment/Dockerfile').read
      backup = root.join('upstream-environments', SAAS, 'Dockerfile')
      backup.dirname.mkpath
      backup.write(original)
      original
    end

    def record(root, base)
      Support.json(root.join('local-overrides.json'), {
                     SAAS => { 'verifier_timeout' => '30m', 'base_image' => base,
                               'original_dockerfile' => "upstream-environments/#{SAAS}/Dockerfile",
                               'reason' => 'Build the same SaaS setup from pinned Fizzy source for local architecture',
                               'requirements_and_assertions' => 'unchanged' }
                   })
    end
  end
end
