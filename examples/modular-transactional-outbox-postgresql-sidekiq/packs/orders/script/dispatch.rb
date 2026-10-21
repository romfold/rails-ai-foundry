# frozen_string_literal: true

require_relative '../../../config/environment'
100.times { break unless Orders::Dispatch.new.call }
puts 'Drained up to 100 due publication intents.'
