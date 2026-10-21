# frozen_string_literal: true

require 'json'
require 'digest'
require_relative 'benchmark_subjects'

module Evidence
  class BenchmarkRun
    CONDITIONS = { 'author' => 'same controlled reference implementation', 'model' => 'none during measurement',
                   'workflow' => 'none', 'measurement' => 'Rails persistence/operation microbenchmark',
                   'onboarding' => 'not measured' }.freeze
    HELD_OUT = [-123, 0, 1, 79, 10_001, nil, '10'].freeze

    def initialize
      ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
      ActiveRecord::Schema.verbose = false
      ActiveRecord::Schema.define { create_table(:entries) { |table| table.integer :cents, null: false } }
    end

    def verify!(subjects)
      subjects.each_value do |subject|
        Entry.delete_all
        HELD_OUT.each do |cents|
          result = subject.call(cents: cents)
          success = result.respond_to?(:success?) ? result.success? : result
          raise 'Held-out result mismatch' unless success == (cents.is_a?(Integer) && cents.positive?)
        end
        raise 'Held-out persistence mismatch' unless Entry.order(:id).pluck(:cents) == [1, 79, 10_001]
      end
      subjects
    end

    def call(trials: 9, iterations: 200)
      validate_size!(trials, iterations)

      subjects = { 'vanilla_rails' => VanillaWrite.new, 'foundry_native' => NativeWrite.new }
      verify!(subjects)
      subjects.each_value { |subject| 50.times { subject.call(cents: 1) } }
      samples = collect(subjects, trials, iterations)
      { 'conditions' => CONDITIONS, 'ruby' => RUBY_VERSION, 'rails' => ActiveRecord.version.to_s,
        'lock_sha256' => Digest::SHA256.file(File.expand_path('../Gemfile.lock', __dir__)).hexdigest,
        'held_out_passed' => true, 'trials' => trials, 'iterations' => iterations, 'samples' => samples,
        'summary' => summarize(samples) }
    end

    private

    def validate_size!(trials, iterations)
      return if trials.between?(5, 100) && iterations.between?(1, 10_000)

      raise ArgumentError, 'Use at least five bounded trials'
    end

    def collect(subjects, trials, iterations)
      trials.times.flat_map do |trial|
        order = trial.even? ? subjects.to_a : subjects.to_a.reverse
        order.map { |name, subject| measure(name, subject, trial, iterations) }
      end
    end

    def measure(name, subject, trial, iterations)
      Entry.delete_all
      GC.start
      allocations = GC.stat(:total_allocated_objects)
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      iterations.times { subject.call(cents: 17) }
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
      allocated = GC.stat(:total_allocated_objects) - allocations
      raise 'Measured behavior mismatch' unless Entry.count == iterations && Entry.sum(:cents) == iterations * 17

      { 'subject' => name, 'trial' => trial, 'elapsed_seconds' => elapsed, 'allocations' => allocated }
    end

    def summarize(samples)
      samples.group_by { |sample| sample.fetch('subject') }.transform_values do |values|
        times = values.map { |value| value.fetch('elapsed_seconds') }.sort
        { 'median_seconds' => times[times.size / 2], 'min_seconds' => times.first, 'max_seconds' => times.last }
      end
    end
  end
end
