# frozen_string_literal: true

module BenchmarkSuite
  module ReviewedStudyFiles
    def configuration
      {
        'version' => 1,
        'environment' => { 'backend' => 'docker', 'workdir' => '/candidate',
                           'network' => { 'mode' => 'none' }, 'build_timeout' => '30m' },
        'agent' => { 'name' => 'nop', 'model' => 'offline-controls', 'timeout' => '20m',
                     'environment' => { 'network' => { 'mode' => 'none' } } },
        'setup' => { 'commands' => ['bash /candidate/bin/prepare-study-db'] },
        'verifier' => { 'logs_dir' => '/tmp/reviewed-logs', 'timeout' => '10m',
                        'command' => 'bundle exec ruby /tests/verify.rb',
                        'restore' => %w[Gemfile Gemfile.lock AGENTS.md TASK.md test config packs.yml package.yml
                                        packwerk.yml bin/prepare-study-db .agents .foundry] }
      }
    end

    def prepare_candidate(candidate, group)
      prepare_dependencies(candidate, group)
      prepare_visible_tests(candidate)
      FileUtils.cp(ROOT.join('reviewed-ai/v1/prepare-db.sh'), candidate.join('bin/prepare-study-db'))
      FileUtils.cp(ROOT.join('reviewed-ai/v1/requirements.md'), candidate.join('TASK.md'))
      candidate.join('AGENTS.md').write(guidance(group))
      candidate.join('public/favicon.ico').write('')
      candidate.join('packwerk.yml').write(<<~YAML)
        require:
        - packwerk-extensions
        exclude:
        - test/**/*
        - tmp/**/*
        - log/**/*
      YAML
    end

    def prepare_dependencies(candidate, group)
      gemfile = candidate.join('Gemfile').read
      if group == 'packs'
        gemfile = gemfile.lines.reject { |line| line.include?("gem 'rails_ai_foundry'") }.join
        gemfile += "gem 'packs', '0.3.0'\ngem 'packwerk', '3.1.0'\ngem 'packwerk-extensions', '0.3.0'\n"
      end
      candidate.join('Gemfile').write(gemfile)
    end

    def prepare_visible_tests(candidate)
      candidate.join('test').mkpath
      %w[test_helper.rb network_guard.rb].each do |name|
        candidate.join('test', name).write(snippets.fetch("test/#{name}"))
      end
      FileUtils.cp(ROOT.join('reviewed-ai/v1/visible_test.rb'), candidate.join('test/visible_test.rb'))
    end

    def guidance(group)
      guidance = 'Use ordinary Rails, packs/packs-rails, Packwerk, RubyLLM and native jobs. Read TASK.md. '
      guidance += if group == 'foundry'
                    'Read installed foundry-plan, foundry-add-feature and foundry-verify skills and references.'
                  else
                    'Inspect the existing application and upstream library APIs. Verify callers, browser and recovery.'
                  end
      "#{guidance}\nDo not modify protected inputs or supplied tests.\n"
    end

    def verifier_files(task, group)
      tests = task.join('tests')
      tests.mkpath
      FileUtils.cp(ROOT.join('reviewed-ai/v1/verify.rb'), tests.join('verify.rb'))
      FileUtils.cp_r(ROOT.join('reviewed-ai/v1/evaluator'), tests.join('test'))
      tests.join('group.txt').write(group)
      upstream_restore(task) if group == 'packs'
    end

    def upstream_restore(task)
      restore = configuration.fetch('verifier').fetch('restore') - %w[.agents .foundry]
      task.join('bench.yml').write({ 'verifier' => { 'restore' => restore } }.to_yaml)
    end

    def dockerfile(group)
      install = if group == 'foundry'
                  "RUN bundle exec rails generate foundry:skills\n"
                else
                  "RUN gem uninstall rails_ai_foundry --all --executables --ignore-dependencies\n"
                end
      <<~DOCKER
        FROM ruby@sha256:9d50d98e61ccbe4f1ef436349911e09b53c42a00364bcd3bda6ac107abc29528
        RUN apt-get update && apt-get install -y --no-install-recommends git build-essential libyaml-dev libpq-dev postgresql chromium chromium-driver && rm -rf /var/lib/apt/lists/*
        WORKDIR /candidate
        COPY gems/ /usr/local/bundle/cache/
        RUN gem install /usr/local/bundle/cache/*.gem --local --ignore-dependencies --no-document
        COPY foundry.gem /tmp/foundry.gem
        RUN gem install --local /tmp/foundry.gem --ignore-dependencies --no-document && rm /tmp/foundry.gem
        COPY candidate/Gemfile ./
        RUN bundle install
        COPY candidate/ ./
        RUN chmod +x bin/rails bin/jobs && mkdir -p public/vendor && cp $(bundle show turbo-rails)/app/assets/javascripts/turbo.js public/vendor/turbo.js
        #{install}RUN mkdir -p /lemans /logs && chown -R postgres:postgres /candidate /lemans /logs
        USER postgres
        RUN git init -q && git add -A && git -c user.name=Benchmark -c user.email=benchmark@example.invalid commit -qm Baseline
        ENV RAILS_ENV=test HOME=/tmp/home PGPORT=55432 PGUSER=postgres PGPASSWORD=foundry SE_CHROMEDRIVER=/usr/bin/chromedriver
      DOCKER
    end
  end
end
