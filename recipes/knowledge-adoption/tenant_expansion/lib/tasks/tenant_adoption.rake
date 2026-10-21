# frozen_string_literal: true

namespace :tenant_adoption do
  task status: :environment do
    puts JSON.pretty_generate(Knowledge::TenantRollout.new.status)
  end

  task backfill: :environment do
    worker = Knowledge::TenantBackfill.new
    worker.start(old_writers_stopped: ENV['OLD_WRITERS_STOPPED'] == 'yes')
    loop { break if worker.batch.zero? }
    puts JSON.pretty_generate(Knowledge::TenantRollout.new.status)
  end

  task resume: :backfill

  task repair: :environment do
    Knowledge::TenantBackfill.new.repair(document_id: Integer(ENV.fetch('DOCUMENT_ID')),
                                         collection_id: Integer(ENV.fetch('REVIEWED_COLLECTION_ID')))
  end

  task validate: :environment do
    Knowledge::TenantConstraints.new.validate
  end

  task cutover: :environment do
    Knowledge::TenantRollout.new.cutover
  end

  task rollback: :environment do
    Knowledge::TenantRollout.new.rollback
  end
end
