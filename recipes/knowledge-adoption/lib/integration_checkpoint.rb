# frozen_string_literal: true

module KnowledgeAdoption
  module IntegrationCheckpoint
    def introduce_integrations(root)
      install_feature_packs(root)
      copy_integration_file('app/jobs', directory: true)
      copy_integration_file('app/services/application_telemetry.rb')
      copy_integration_file('config/initializers', directory: true)
      %w[config/routes.rb config/ai.yml config/queue.yml config/recurring.yml bin/jobs].each do |path|
        copy_integration_file(path)
      end
      write('packs.yml', YAML.dump('pack_paths' => ["#{root}/*", 'app/jobs', 'config/initializers']))
      preserve_delivery(root)
      preserve_document_json(root)
      rewrite_roots(root)
      add_integration_migrations
    end

    private

    def preserve_delivery(root)
      settings = File.join(@app, 'config/initializers/native_services.rb')
      File.write(settings, File.read(settings).sub(/"foundry_knowledge_[^"\n]+"/, @database.inspect))
      view = File.join(@app, root, 'knowledge/app/views/knowledge/documents/index.html.erb')
      File.write(view, File.read(view).sub('<h1>Published knowledge</h1>', '<h1>Knowledge documents</h1>'))
    end

    def preserve_document_json(root)
      # Adoption retains its characterized JSON array; pagination is additive through a response header.
      path = File.join(@app, root, 'knowledge/app/controllers/knowledge/documents_controller.rb')
      source = File.read(path).sub('render json: { documents: @documents, next_cursor: @documents.last&.fetch(:id) }',
                                   'response.set_header("X-Next-Cursor", @documents.last&.fetch(:id)); ' \
                                   'render json: @documents')
      File.write(path, source)
    end

    def install_feature_packs(root)
      install_integration_gems
      FileUtils.rm_rf(File.join(@app, @pack))
      %w[access knowledge search answering].each do |name|
        FileUtils.cp_r(File.join(INTEGRATION, 'packs', name), File.join(@app, root, name))
      end
      FileUtils.rm_rf(File.join(@app, 'app/services/access'))
      FileUtils.rm_rf(File.join(@app, 'app/controllers/access'))
      FileUtils.rm_rf(File.join(@app, 'app/views/access'))
    end

    def install_integration_gems
      gems = %w[rails_event_store elasticsearch ruby_llm ruby_llm-schema solid_queue]
      lines = File.readlines(File.join(INTEGRATION, 'Gemfile'))
      append_gems(lines.select { |line| gems.any? { |name| line.include?("gem '#{name}'") } }.join)
    end

    def add_integration_migrations
      original = File.read(File.join(INTEGRATION, 'db/migrate/20260916000001_create_knowledge.rb'))
      original = original.sub('class CreateKnowledge', 'class AddKnowledgeIntegrations').sub("    documents\n", '')
      from = original.index('  def documents')
      to = original.index('  def deliveries', from)
      original[from...to] = ''
      write('db/migrate/20260916000002_add_knowledge_integrations.rb', original)
      copy_service_migrations
    end

    def copy_service_migrations
      Dir[File.join(INTEGRATION, 'db/migrate/*')].reject { |path| path.end_with?('create_knowledge.rb') }.each do |path|
        write("db/migrate/#{File.basename(path)}", File.read(path))
      end
    end

    def rewrite_roots(root)
      return if root == 'packs'

      Dir[File.join(@app, '**/package.yml')].each do |path|
        File.write(path, File.read(path).gsub('packs/', "#{root}/"))
      end
      contract = File.join(@app, root, 'answering/app/prompts/answering/provider_answer/contract.yml')
      File.write(contract, File.read(contract).sub('owner: packs/', "owner: #{root}/"))
    end
  end
end
