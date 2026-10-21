# frozen_string_literal: true

require_relative 'support'

module BenchmarkSuite
  # An explicit environment override for the pinned upstream task's online gem-install setup.
  module Prerequisites
    TASK = 'ft-i18n-support'
    COMMAND = 'gem install rails-i18n -v 8.1.0'

    module_function

    def prepare(root)
      dockerfile = root.join('docker/fizzy/Dockerfile')
      image = Lemans::Config::ImageSpec.dockerfile(dockerfile, slug: 'fizzy')
      directory = root.join('local-environments/i18n')
      directory.mkpath
      directory.join('Dockerfile').write("FROM #{image.name}\nRUN #{COMMAND} --no-document\n")
      profile = { 'image' => nil, 'dockerfile' => '../../local-environments/i18n/Dockerfile' }
      override = { 'environment' => { 'network' => { 'mode' => 'public' }, 'profiles' => { 'fizzy' => profile } } }
      root.join('tasks', TASK, 'bench.yml').write(override.to_yaml)
      Support.json(root.join('prerequisites.json'), { TASK => { 'command' => COMMAND, 'gem' => 'rails-i18n',
                                                                'version' => '8.1.0', 'base_image' => image.name } })
    end

    def commands(task, root)
      return {} unless task.name == TASK && Pathname(root).join('prerequisites.json').file?

      script = "Gem::Specification.find_by_name('rails-i18n', '= 8.1.0')"
      validation = "ruby -e #{Shellwords.escape(script)}"
      { COMMAND => validation }
    end
  end
end
