# frozen_string_literal: true

require_relative '../version'

gem 'packs-rails', '~> 0.1.0'
gem 'dry-operation', '~> 1.1'
gem 'solid_queue', '~> 1.7.0'
# Verified Rails 7.1/8.1 JSON decoding still passes positional parser options.
gem 'json', '>= 2.9', '< 3'
gem_group :development, :test do
  gem 'rails_ai_foundry', RailsAIFoundry::VERSION
  gem 'minitest', '< 6' if Rails.gem_version < Gem::Version.new('8.0')
end

# PostgreSQL provides the optional Cable transport without another service.
gsub_file 'Gemfile', /^gem ["']redis["'].*\n/, ''
gsub_file 'config/cable.yml', /adapter: redis/,
          options[:database] == 'postgresql' ? 'adapter: postgresql' : 'adapter: async'
gsub_file 'config/cable.yml', /^\s*url:.*REDIS_URL.*\n/, ''

create_file 'config/foundry.yml', <<~YAML
  workload: balanced
  defaults:
    profile: rails_native
    patterns:
      events: none
      cqrs: none
YAML
create_file 'packwerk.yml', "require:\n- packwerk-extensions\n"
create_file 'package.yml', "enforce_dependencies: true\nenforce_privacy: true\n"
empty_directory 'packs'

after_bundle do
  if options[:skip_bundle]
    say 'Bundle installation and Rails integration installers are pending; see the foundry new output.'
  else
    unless generate 'solid_queue:install'
      raise 'Solid Queue installation failed; inspect the generated application before retrying.'
    end

    # Upstream documents copying its schema into a migration for a single database.
    schema = File.read(File.join(destination_root, 'db/queue_schema.rb'))
    unless schema.start_with?('ActiveRecord::Schema[7.1].define(version: 1) do')
      raise 'Unexpected Solid Queue schema; review the upstream single-database installation instructions.'
    end

    body = schema.lines[1...-1].map { |line| "  #{line}" }.join.gsub(', force: :cascade', '')
    migration = "class CreateSolidQueueTables < ActiveRecord::Migration[7.1]\n  def change\n#{body}  end\nend\n"
    create_file "db/migrate/#{Time.now.utc.strftime('%Y%m%d%H%M%S')}_create_solid_queue_tables.rb", migration
    remove_file 'db/queue_schema.rb'
    gsub_file 'config/environments/production.rb', /^\s*config\.solid_queue\.connects_to.*\n/, ''
    environment 'config.active_job.queue_adapter = :solid_queue'
    environment 'config.active_job.queue_adapter = :test', env: 'test'
    create_file '.foundry/native-application.yml', "schema: 1\nqueue: solid_queue\n"
  end
end
