# frozen_string_literal: true

require_relative 'replay'

module KnowledgeAdoption
  class TenantReplay < Replay
    TENANT_FIXTURE = File.expand_path('../tenant_app', __dir__)
    EXPANSION = File.expand_path('../tenant_expansion', __dir__)

    private

    def replay(root)
      prepare_application(root)
      verify('01-characterize')
      assess
      extraction_checkpoints(root)
      preserve_customizations
      expand
      command('bundle', 'exec', 'rails', 'test')
      demonstrate_rollout
      verify('05-tenant-cutover')
      verify_fresh_schema
      verify_faults
      command('bundle', 'exec', 'foundry', 'check', '--sources', '--boundaries')
      verify_preserved
    end

    def verify_preserved
      raise 'Customized application files changed' unless @preserved.all? do |path, hash|
        Digest::SHA256.file(File.join(@app, path)).hexdigest == hash
      end
    end

    def prepare_application(root)
      @pack = nil
      @app = File.join(@directory, root)
      FileUtils.cp_r(TENANT_FIXTURE, @app)
      @database = "foundry_tenant_adoption_#{Process.pid}_#{root}"
      @workflow = hashes('openspec/**/*')
      gemfile = File.read(File.join(@app, 'Gemfile')).sub("path: '../../..'", "'1.0.0', require: false")
      write('Gemfile', gemfile)
      command('bundle', 'install', '--local', frozen: false)
      command('bundle', 'exec', 'rails', 'db:prepare')
      seed
    end

    def seed
      command('bundle', 'exec', 'rails', 'runner', "require Rails.root.join('test/support/seed'); TenantSeed.reset!")
    end

    def verify(checkpoint)
      verify_continuity
      command('bundle', 'exec', 'rails', 'test', 'test/characterization_test.rb')
      command('bundle', 'exec', 'rails', 'runner', 'Rails.application.eager_load!')
      verify_assessment if @pack
      command(File.join(SOURCE, 'node_modules/.bin/openspec'), 'validate', '--all', '--strict', '--no-interactive')
      verify_continuity
      raise 'Established workflow changed' unless @workflow == hashes('openspec/**/*')

      @results << { checkpoint: checkpoint, root: File.basename(@app), gem_sha256: @archive_hash,
                    workflow_sha256: @workflow, source_sha256: hashes('{app,config,packs,components}/**/*') }
    end

    def verify_continuity
      command('bundle', 'exec', 'rails', 'runner', <<~RUBY)
        require Rails.root.join('test/support/seed')
        TenantSeed.verify!
      RUBY
    end

    def move_knowledge
      %w[models services controllers].each do |area|
        destination = File.join(@app, @pack, 'app', area)
        FileUtils.mkdir_p(destination)
        FileUtils.mv(File.join(@app, 'app', area, 'knowledge'), destination)
      end
    end

    def preserve_customizations
      write('.agents/skills/foundry-add-feature/SKILL.md', 'Application-owned feature instructions')
      write('AGENTS.md', 'Preserved project instructions')
      write('.agents/skills/unrelated/SKILL.md', 'Unrelated application skill')
      write("#{@pack}/package_todo.yml", "# Reviewed empty baseline\n{}\n")
      patterns = ['{.agents,openspec}/**/*', '**/package_todo.yml', 'AGENTS.md',
                  '.foundry/skills/*', 'config/foundry.yml']
      @preserved = patterns.each_with_object({}) { |pattern, result| result.merge!(hashes(pattern)) }
      command('bundle', 'exec', 'rails', 'generate', 'foundry:skills')
    end

    def expand
      Dir.glob('**/*', base: EXPANSION).each do |path|
        next unless File.file?(File.join(EXPANSION, path))

        destination = path.start_with?('app/', 'lib/tasks/') ? "#{@pack}/#{path}" : path
        write(destination, File.binread(File.join(EXPANSION, path)))
      end
      command('bundle', 'exec', 'rails', 'db:migrate')
    end

    def demonstrate_rollout
      seed
      command('bundle', 'exec', 'rails', 'runner', <<~RUBY)
        worker = Knowledge::TenantBackfill.new
        worker.start(old_writers_stopped: true)
        loop { break if worker.batch.zero? }
        raise 'Unmapped record was not retained' unless Knowledge::TenantIssue.exists?(document_id: 1201)
        Knowledge::Collection.find(4).update!(tenant_id: 'tenant-c')
        worker.repair(document_id: 1201, collection_id: 4)
      RUBY
      command('bundle', 'exec', 'rails', 'tenant_adoption:validate', 'tenant_adoption:cutover',
              'tenant_adoption:status')
      command('bundle', 'exec', 'rails', 'db:schema:dump')
    end

    def verify_fresh_schema
      original = @database
      @database = "#{original}_fresh"
      write('db/structure.sql', File.binread(File.join(EXPANSION, 'db/structure.sql')))
      command('bundle', 'exec', 'rails', 'db:create', 'db:schema:load')
      command('bundle', 'exec', 'rails', 'runner', <<~RUBY)
        raise 'Missing constraints' unless Knowledge::TenantConstraints.new.validated?
        Knowledge::Collection.create!(tenant_id: 'tenant-a', name: 'Fresh')
        catalog = Rails.configuration.x.knowledge
        row = catalog.create(tenant: 'tenant-a', collection_id: Knowledge::Collection.first.id, title: 'Fresh', body: 'Body')
        raise 'Fresh writer missing ownership' unless Knowledge::Document.find(row['id']).tenant_id == 'tenant-a'
        raise 'Fresh isolation failed' unless catalog.list(tenant: 'tenant-b').empty?
        Knowledge::TenantBackfill.new.start(old_writers_stopped: true)
      RUBY
    ensure
      command('bundle', 'exec', 'rails', 'db:drop') if @database != original
      @database = original
    end

    def verify_faults
      %w[default_owner skipped_batch unsafe_cutover authorization].each do |fault|
        output = command('bundle', 'exec', 'rails', 'test', 'test/fault_controls.rb',
                         '--name', "/#{fault}/", expected: 1)
        raise 'Fault did not fail a behavioral assertion' unless output.match?(/1 failures, 0 errors/)
      end
      demonstrate_rollout
    end
  end
end
