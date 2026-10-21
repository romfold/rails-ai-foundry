# frozen_string_literal: true

# Invoke through Rails runner with RAILS_ENV=test. This resets only the named disposable test application.
require 'timeout'
require 'digest'
require 'socket'
require_relative 'loopback_only'
Socket.singleton_class.prepend(LoopbackOnly::SocketMethods)
TCPSocket.singleton_class.prepend(LoopbackOnly::TCPMethods)

class ProjectionMeasurement
  def initialize(count)
    raise ArgumentError, 'Choose 1000 or 10000 documents' unless [1000, 10_000].include?(count)
    raise 'Disposable test database required' unless Rails.env.test? &&
                                                     ActiveRecord::Base.connection.current_database ==
                                                     'foundry_knowledge_test'

    @count = count
    @catalog = Rails.configuration.x.knowledge
    @search = Rails.configuration.x.search
    @report = { documents: count, dimensions: 1536, seed: 17, status: 'running', stages: {}, measurements: {} }
    @index = Search::ElasticIndex.new(url: 'http://127.0.0.1:59210', name: 'foundry_knowledge_test')
    @queries = 0
  end

  def call
    Timeout.timeout(600) do
      reset
      observe
      run_stages
      @report.merge!(status: 'passed', query_count: @queries, versions: versions, source_sha256: source_hash)
    end
  rescue StandardError => e
    @report.merge!(status: e.is_a?(Timeout::Error) ? 'timeout' : 'failed', error: e.class.name)
    raise
  ensure
    ActiveSupport::Notifications.unsubscribe(@subscriber) if @subscriber
    ActiveSupport::Notifications.unsubscribe(@sql_subscriber) if @sql_subscriber
    puts JSON.pretty_generate(@report)
  end

  private

  def run_stages
    stage('seed') { seed }
    stage('search_rebuild_recovery') { recover_search }
    stage('vector_rebuild') { @search.rebuild_vectors(version: 'measure-v2') }
    stage('retrieval') { retrieval }
    @report[:query_plan] = query_plan
  end

  def reset
    ActiveRecord::Base.connection.execute(
      'TRUNCATE search_rebuild_entries, search_rebuild_runs, knowledge_projection_changes, ' \
      'knowledge_deliveries, knowledge_documents, search_vectors, search_settings, ' \
      'event_store_events_in_streams, event_store_events RESTART IDENTITY CASCADE'
    )
    @index.client.indices.get(index: 'foundry_knowledge_test*').each_key do |name|
      @index.client.indices.delete(index: name)
    end
    @search.setup
  end

  def seed
    model = Class.new(ActiveRecord::Base) { self.table_name = 'knowledge_documents' }
    (1..@count).each_slice(250) do |numbers|
      model.insert_all!(numbers.map do |number|
        { id: format('00000000-0000-0000-0000-%012d', number), tenant_id: tenant(number),
          title: "Refund policy #{number}", body: "Refund payment within thirty days. Document #{number}.",
          status: 'published', revision: 1, created_at: Time.utc(2026, 9, 17), updated_at: Time.utc(2026, 9, 17) }
      end)
    end
    # Fixture creation represents existing committed data; measured mutations use the public catalog.
  end

  def tenant(number)
    return 'tenant-a' if number <= @count * 0.8
    return 'tenant-b' if number <= @count * 0.95

    'tenant-c'
  end

  def recover_search
    run = @search.start_rebuild(destination: 'search')
    @search.resume_rebuild(run[:id])
    begin
      @search.resume_rebuild(run[:id], after_write: -> { raise IOError, 'controlled interruption' })
    rescue IOError
      raise 'Checkpoint advanced after interruption' if @search.rebuild_status(run[:id])[:page_key]
    end
    started = monotonic
    @search.rebuild_search(run_id: run[:id])
    @report[:recovery_seconds] = monotonic - started
    raise 'Incomplete search membership' unless @index.count(run[:candidate]) == @count
  end

  def retrieval
    principal = Access::Identity.authenticate('demo-a')
    @search.retrieve(principal: principal, query: 'refund')
    samples = Array.new(5) do
      started = monotonic
      result = @search.retrieve(principal: principal, query: 'refund')
      validate_retrieval!(result, principal)

      (monotonic - started) * 1000
    end.sort
    @report[:retrieval] = { samples_ms: samples, p50_ms: samples[2], p95_ms: samples[4] }
  end

  def validate_retrieval!(result, principal)
    valid = result[:documents].size == 5 && !result[:incomplete] &&
            result[:documents].all? { |document| document[:tenant_id] == principal.tenant_id }
    raise 'Invalid retrieval result' unless valid
  end

  def observe
    @sql_subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') { @queries += 1 }
    @subscriber = ActiveSupport::Notifications.subscribe(/\.knowledge\z/) do |name, _start, _finish, _id, payload|
      record(name, payload)
    end
    observe_queries
  end

  def observe_queries
    databases = [@catalog.instance_variable_get(:@database).connection,
                 @search.instance_variable_get(:@vectors).send(:database),
                 @search.instance_variable_get(:@runs).send(:database)]
    counter = Object.new
    increment = -> { @queries += 1 }
    counter.define_singleton_method(:info) { |*| increment.call }
    counter.define_singleton_method(:error) { |*| increment.call }
    databases.each { |database| database.loggers << counter }
  end

  def record(name, payload)
    metrics = (@report[:measurements][name] ||= {})
    payload.each do |key, value|
      next unless value.is_a?(Numeric)

      metrics[key] = [metrics.fetch(key, 0), value].max
    end
    validate_bounds!(name, payload)
  end

  def validate_bounds!(name, payload)
    raise 'Unbounded rebuild batch' if name == 'rebuild_batch.knowledge' &&
                                       (payload[:rows] > 250 || payload[:bytes] > 1_048_576)
    raise 'Unbounded retrieval' if name == 'retrieval_budget.knowledge' && payload[:candidates] > 100
  end

  def stage(name)
    started = monotonic
    allocations = GC.stat(:total_allocated_objects)
    queries = @queries
    yield
  ensure
    @report[:stages][name] = { seconds: monotonic - started, queries: @queries - queries,
                               allocated_objects: GC.stat(:total_allocated_objects) - allocations }
  end

  def query_plan
    database = @search.instance_variable_get(:@vectors).send(:database)
    vector = JSON.generate(Search::DemoEmbeddings.new.call('refund'))
    sql = 'EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) SELECT document_id, revision FROM search_vectors ' \
          'WHERE tenant_id = ? AND version = ? ORDER BY embedding <=> ?::vector, document_id LIMIT 20'
    raw = database.fetch(sql, 'tenant-a', 'measure-v2', vector).first.values.first
    raw.is_a?(String) ? JSON.parse(raw) : raw
  end

  def versions
    { ruby: RUBY_VERSION, host: RbConfig::CONFIG.fetch('host'),
      elasticsearch: @index.client.info.dig('version', 'number'),
      postgres: ActiveRecord::Base.connection.select_value('SHOW server_version'),
      lock_sha256: Digest::SHA256.file(Rails.root.join('Gemfile.lock')).hexdigest }
  end

  def source_hash
    paths = Dir.glob(Rails.root.join('{app,packs,config,db/migrate,lib,script,test/support}/**/*')).select do |path|
      File.file?(path)
    end.sort
    Digest::SHA256.hexdigest(paths.map { |path| "#{path.delete_prefix(Rails.root.to_s)}:#{Digest::SHA256.file(path).hexdigest}" }
                                 .join("\n"))
  end

  def monotonic
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end
