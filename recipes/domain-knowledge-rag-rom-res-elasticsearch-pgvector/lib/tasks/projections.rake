# frozen_string_literal: true

namespace :projections do
  desc 'Start an operator rebuild: DESTINATION=search|vectors VERSION=...'
  task start: :environment do
    puts Rails.configuration.x.search.start_rebuild(destination: ENV.fetch('DESTINATION'),
                                                    version: ENV.fetch('VERSION', nil)).to_json
  end

  desc 'Inspect a rebuild: RUN_ID=...; omit RUN_ID for the 20 most recent runs'
  task status: :environment do
    puts Rails.configuration.x.search.rebuild_status(ENV.fetch('RUN_ID', nil)).to_json
  end

  desc 'Perform one recoverable rebuild unit: RUN_ID=...'
  task resume: :environment do
    Rails.configuration.x.search.resume_rebuild(ENV.fetch('RUN_ID'), repair: ENV['REPAIR'] == '1')
    puts Rails.configuration.x.search.rebuild_status(ENV.fetch('RUN_ID')).to_json
  end

  desc 'Cancel inactive processing: RUN_ID=... (unresolved cutovers must be reconciled)'
  task cancel: :environment do
    Rails.configuration.x.search.cancel_rebuild(ENV.fetch('RUN_ID'))
    puts Rails.configuration.x.search.rebuild_status(ENV.fetch('RUN_ID')).to_json
  end

  desc 'Preview terminal inactive candidate cleanup: RUN_ID=... CONFIRM=delete to execute'
  task cleanup: :environment do
    puts Rails.configuration.x.search.cleanup_rebuild(ENV.fetch('RUN_ID'), confirm: ENV['CONFIRM'] == 'delete').to_json
  end
end
