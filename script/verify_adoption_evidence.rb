#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'rails_ai_foundry/conventions/debt_audit'

source = File.expand_path('../examples/modular-legacy-adoption-packwerk', __dir__)
pks = ENV.fetch('PKS_BIN', 'pks')
audit = RailsAIFoundry::Conventions::DebtAudit.new(source, pks: pks)
original = audit.snapshot.fingerprint
puts 'Running Packwerk and pks validation/regeneration in disposable copies of the adoption app.'
report = audit.call(parity: true)
report.fetch('commands').each do |command|
  puts command.fetch('argv').join(' ')
  puts command.fetch('stdout')
  warn command.fetch('stderr') unless command.fetch('stderr').empty?
end
raise 'Expected matching two accepted identities' unless report['success'] && report['retained'].size == 2
raise 'Fresh parity verification failed' unless audit.verify(report)['success']

puts JSON.pretty_generate(report.slice('tools', 'parity', 'source_unchanged', 'fingerprint'))

audit.snapshot.copy do |copy|
  # The copied app must use its original installed path gem; no bundle resolution is performed.
  gemfile = File.join(copy, 'Gemfile')
  File.write(gemfile, File.read(gemfile).sub("path: '../..'", "path: #{File.expand_path('..', __dir__).inspect}"))
  lock = File.join(copy, 'Gemfile.lock')
  File.write(lock, File.read(lock).sub('remote: ../..', "remote: #{File.expand_path('..', __dir__)}"))
  candidate = RailsAIFoundry::Conventions::DebtAudit.new(copy, pks: pks)
  File.write(File.join(copy, 'app/services/legacy_sales_report.rb'), "class LegacySalesReport; end\n")
  resolved = candidate.call
  raise 'Fully resolved debt was not detected' unless resolved['success'] && resolved['resolved'].size == 2

  puts 'Fully resolved debt: two identities reported; accepted baseline retained.'
  File.write(File.join(copy, 'app/services/new_report.rb'),
             "class NewReport; def total; Billing::Invoice.count; end; end\n")
  added = candidate.call
  raise 'New debt was not rejected' unless !added['success'] && added['new'].size == 2

  puts 'New source debt: two identities rejected.'
end
raise 'Original app changed' unless original == audit.snapshot.fingerprint

puts 'Adoption/parity acceptance passed; original application and baseline bytes preserved.'
