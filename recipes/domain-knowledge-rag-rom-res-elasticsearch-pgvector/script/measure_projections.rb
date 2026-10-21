# frozen_string_literal: true

# Contributor-only disposable fixture; never load it during application execution.
require_relative '../test/support/projection_measurement'
ProjectionMeasurement.new(Integer(ARGV.fetch(0))).call
