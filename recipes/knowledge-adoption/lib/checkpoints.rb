# frozen_string_literal: true

require_relative 'integration_checkpoint'

module KnowledgeAdoption
  module Checkpoints
    include IntegrationCheckpoint

    def extract(root)
      @pack = "#{root}/knowledge"
      move_knowledge
      write('package.yml', "enforce_dependencies: true\ndependencies: []\n")
      write('config/initializers/package.yml', YAML.dump('enforce_dependencies' => true, 'dependencies' => [@pack]))
      write('packs.yml', YAML.dump('pack_paths' => ["#{root}/*", 'config/initializers']))
      write("#{@pack}/package.yml", YAML.dump('enforce_dependencies' => true, 'enforce_privacy' => true,
                                              'dependencies' => ['.']))
      write("#{@pack}/foundry.yml", YAML.dump('namespace' => 'Knowledge', 'profile' => 'modular'))
      write('config/foundry.yml', YAML.dump('schema' => 1, 'workflow' => { 'specs' => 'openspec' }))
      copy_integration_file('packwerk.yml')
      append_gems("gem 'packs-rails', '0.1.0'\n")
    end

    def repair_callers
      source = "#{@pack}/app/services/knowledge/catalog.rb"
      destination = "#{@pack}/app/public/knowledge/catalog.rb"
      write(destination, File.read(File.join(@app, source)))
      FileUtils.rm(File.join(@app, source))
    end

    def introduce_rom
      append_gems("gem 'rom-sql', '3.7.0'\n")
      FileUtils.rm_rf(File.join(@app, @pack, 'app/models/knowledge'))
      %w[change_document document_policy].each do |name|
        FileUtils.rm(File.join(@app, @pack, 'app/services/knowledge', "#{name}.rb"))
      end
      %w[app/adapters/knowledge/database.rb app/application/knowledge/commands/change_document.rb
         app/domain/knowledge/document_policy.rb app/public/knowledge/catalog.rb].each do |path|
        content = File.read(File.join(INTEGRATION, 'packs/knowledge', path))
        write("#{@pack}/#{path}", content)
      end
      copy_integration_file('config/initializers/knowledge_limits.rb')
      prepare_rom_without_delivery
      write("#{@pack}/foundry.yml", YAML.dump('namespace' => 'Knowledge', 'profile' => 'domain',
                                              'capabilities' => { 'persistence' => { 'adapter' => 'rom' } }))
      write('config/initializers/native_services.rb', <<~CODE)
        # frozen_string_literal: true
        Rails.application.reloader.to_prepare do
          config = ActiveRecord::Base.connection_db_config.configuration_hash
          url = "postgres://\#{config.fetch(:username)}:\#{config.fetch(:password)}@\#{config.fetch(:host)}:" \\
                "\#{config.fetch(:port)}/\#{config.fetch(:database)}"
          Rails.configuration.x.knowledge = Knowledge::Catalog.new(url: url)
        end
      CODE
    end

    private

    def move_knowledge
      %w[models services controllers views].each do |area|
        source = File.join(@app, 'app', area, 'knowledge')
        destination = File.join(@app, @pack, 'app', area)
        FileUtils.mkdir_p(destination)
        FileUtils.mv(source, destination)
      end
    end

    def prepare_rom_without_delivery
      remove_publication_intent
      path = "#{@pack}/app/public/knowledge/catalog.rb"
      content = File.read(File.join(@app, path)).sub('database: @database, queue: queue', 'database: @database')
      from = content.index('    def queue')
      to = content.index('    def disconnect', from)
      content[from...to] =
        "    def delivery_status(principal:)\n      " \
        "Access::Identity.authorize!(principal, principal.tenant_id)\n      {}\n    end\n\n"
      write(path, content)
    end

    def remove_publication_intent
      path = "#{@pack}/app/application/knowledge/commands/change_document.rb"
      content = File.read(File.join(@app, path)).sub('database:, queue:', 'database:')
                    .lines.reject { |line| line.include?('@queue') || line.strip == 'record_intent(document)' }.join
      write(path, content)
    end

    def copy_integration_file(path, directory: false)
      destination = File.join(@app, path)
      FileUtils.mkdir_p(File.dirname(destination))
      FileUtils.rm_rf(destination) if directory
      FileUtils.cp_r(File.join(INTEGRATION, path), destination)
    end

    def append_gems(content)
      File.open(File.join(@app, 'Gemfile'), 'a') { |file| file.puts(content) }
      command('bundle', 'install', '--local', frozen: false)
    end

    def write(path, content)
      destination = File.join(@app, path)
      FileUtils.mkdir_p(File.dirname(destination))
      File.write(destination, content)
    end
  end
end
