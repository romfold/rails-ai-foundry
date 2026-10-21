# frozen_string_literal: true

module TenantSeed
  def self.reset!
    connection = ActiveRecord::Base.connection
    if connection.table_exists?('knowledge_tenant_migrations')
      %w[knowledge_tenant_present knowledge_collection_owner].each do |name|
        connection.execute("ALTER TABLE knowledge_documents DROP CONSTRAINT IF EXISTS #{name}")
      end
      connection.execute('TRUNCATE knowledge_tenant_migrations, knowledge_tenant_issues')
      connection.execute('INSERT INTO knowledge_tenant_migrations (id) VALUES (1)')
    end
    connection.execute('TRUNCATE knowledge_documents, knowledge_collections RESTART IDENTITY CASCADE')
    connection.execute(<<~SQL)
      INSERT INTO knowledge_collections (id, tenant_id, name)
      VALUES (1, 'tenant-a', 'A'), (2, 'tenant-b', 'B'), (3, 'tenant-c', 'C'), (4, NULL, 'Unmapped import');
      INSERT INTO knowledge_documents (id, collection_id, title, body, revision, created_at, updated_at)
      SELECT n, ((n - 1) % 3) + 1, 'Existing ' || n, 'Body ' || n, 7, '2026-09-01', '2026-09-01'
      FROM generate_series(1,1200) n;
      INSERT INTO knowledge_documents (id, collection_id, title, body, revision, created_at, updated_at)
      VALUES (1201, 4, 'Unmapped', 'Import', 7, '2026-09-01', '2026-09-01');
      SELECT setval('knowledge_documents_id_seq', 1201);
      SELECT setval('knowledge_collections_id_seq', 4);
    SQL
  end

  def self.verify!
    sql = 'SELECT * FROM knowledge_documents WHERE id <= 1201 ORDER BY id'
    rows = ActiveRecord::Base.connection.select_all(sql).to_a
    raise 'Existing records lost' unless rows.size == 1201

    rows.each { |row| verify_row!(row) }
  end

  def self.verify_row!(row)
    id = row.fetch('id')
    expected = { 'title' => id == 1201 ? 'Unmapped' : "Existing #{id}",
                 'body' => id == 1201 ? 'Import' : "Body #{id}", 'revision' => 7 }
    raise 'Existing content changed' unless row.slice(*expected.keys) == expected
    raise 'Existing timestamps changed' unless %w[created_at updated_at].all? do |key|
      row.fetch(key).to_date.to_s == '2026-09-01'
    end
  end
end
