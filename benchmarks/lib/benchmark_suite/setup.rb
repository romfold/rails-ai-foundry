# frozen_string_literal: true

require_relative 'support'

module BenchmarkSuite
  # Replays declared setup in a fresh container; no agent installation or execution.
  module Setup
    module_function

    def apply(container, setup, seed: false, prepared_commands: {})
      setup.files.each { |local, relative| container.upload(local, File.join('/lemans/setup', relative)) }
      if seed
        container.exec!('git apply --binary --whitespace=nowarn /lemans/setup/environment.patch')
        container.exec!('rm -rf .git && git init -q && git add -A && ' \
                        'git -c user.name=Verification -c user.email=verification@example.invalid commit -qm Baseline')
      end
      setup.commands.each { |command| container.exec!(prepared_commands.fetch(command, command)) }
      container.exec!('find /lemans -mindepth 1 -delete')
    end
  end
end
