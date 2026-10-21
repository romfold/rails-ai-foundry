# frozen_string_literal: true

module KnowledgeAdoption
  module ReplayHost
    private

    def install_archive
      build = File.join(@directory, 'build')
      copy_archive_sources(build)
      archive = Dir.chdir(build) { File.expand_path(Gem::Package.build(Gem::Specification.load('rails_ai_foundry.gemspec'))) }
      @archive_hash = Digest::SHA256.file(archive).hexdigest
      system(RbConfig.ruby, '-S', 'gem', 'install', archive, '--local', '--ignore-dependencies', '--no-document',
             '--install-dir', @gem_home, exception: true)
    end

    def copy_archive_sources(build)
      specification = Dir.chdir(SOURCE) { Gem::Specification.load('rails_ai_foundry.gemspec') }
      (specification.files + ['rails_ai_foundry.gemspec']).each do |path|
        destination = File.join(build, path)
        FileUtils.mkdir_p(File.dirname(destination))
        FileUtils.cp(File.join(SOURCE, path), destination, preserve: true)
      end
    end

    def command(*arguments, frozen: true, expected: 0)
      environment = command_environment(frozen)
      puts "$ #{arguments.shelljoin} (#{@app})"
      output, error, status = Bundler.with_unbundled_env do
        Open3.capture3(environment, *arguments, chdir: @app)
      end
      [output, error].each { |stream| stream.force_encoding(Encoding::UTF_8) }
      puts output unless output.empty?
      warn error unless error.empty?
      unless status.exitstatus == expected
        raise "Expected exit #{expected}, received #{status.exitstatus}: #{arguments.shelljoin}"
      end

      output
    end

    def command_environment(frozen)
      { 'GEM_HOME' => @gem_home, 'GEM_PATH' => ([@gem_home] + Gem.path).join(File::PATH_SEPARATOR),
        'BUNDLE_GEMFILE' => File.join(@app, 'Gemfile'), 'BUNDLE_FROZEN' => frozen.to_s,
        'RAILS_ENV' => 'test', 'ADOPTION_DATABASE' => @database, 'DATABASE_URL' => nil,
        'RUBYLIB' => nil, 'RUBYOPT' => nil }
    end

    def hashes(glob)
      Dir.glob(glob, File::FNM_DOTMATCH, base: @app).sort.filter_map do |path|
        next if path.match?(%r{\A(?:log|tmp|\.bundle)/}) || !File.file?(File.join(@app, path))

        [path, Digest::SHA256.file(File.join(@app, path)).hexdigest]
      end.to_h
    end

    def seed
      command('bundle', 'exec', 'rails', 'runner', <<~CODE)
        ActiveRecord::Base.connection.execute(<<~SQL)
          INSERT INTO knowledge_documents (id, tenant_id, title, body, status, revision, created_at, updated_at)
          VALUES ('00000000-0000-4000-8000-000000000007', 'tenant-b', 'Existing refund policy',
                  'Refund within thirty days', 'published', 7, '2026-09-01', '2026-09-01')
        SQL
      CODE
    end

    def verify_continuity
      command('bundle', 'exec', 'rails', 'runner', <<~CODE)
        row = ActiveRecord::Base.connection.select_one("SELECT * FROM knowledge_documents WHERE id = '00000000-0000-4000-8000-000000000007'")
        expected = { 'tenant_id' => 'tenant-b', 'title' => 'Existing refund policy', 'body' => 'Refund within thirty days',
                     'revision' => 7, 'status' => 'published' }
        raise 'Existing data changed' unless row.slice(*expected.keys) == expected
        raise 'Existing timestamps changed' unless row['created_at'].to_date.to_s == '2026-09-01' && row['updated_at'].to_date.to_s == '2026-09-01'
      CODE
    end

    def verify_integrations
      command('bundle', 'exec', 'rails', 'runner', <<~CODE)
        Rails.configuration.x.search.setup
        DeliveryPollJob.perform_now
        Rails.configuration.x.search.rebuild_search
        Rails.configuration.x.search.rebuild_vectors(version: 'adopted-v1')
        principal = Access::Identity.authenticate('demo-b')
        answer = Answering::Answers.new(catalog: Rails.configuration.x.knowledge, search: Rails.configuration.x.search)
                                  .call(principal: principal, question: 'refund')
        raise 'Existing document not retrievable' unless answer.fetch('citations').include?('00000000-0000-4000-8000-000000000007')
      CODE
      command('bundle', 'exec', 'foundry', 'check', '--sources', '--prompts')
      command('bundle', 'exec', 'foundry', 'check', '--boundaries')
    end
  end
end
