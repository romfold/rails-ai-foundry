# frozen_string_literal: true

module FoundrySkillVerification
  class RSpecEvidence
    def initialize(path, phase, files, selection)
      @phase = phase
      @files = files
      @selection = selection
      raise Failure, "#{phase}: test process produced no RSpec evidence." unless File.file?(path)

      @report = JSON.parse(File.read(path))
      LoadedFiles.verify(@report, files) if phase == 'baseline' && selection.include_pack_tests
      @rows = @report.fetch('examples')
      validate_shape
    rescue JSON::ParserError, KeyError, TypeError, NoMethodError
      raise Failure, "#{phase}: invalid RSpec evidence."
    end

    def verify
      verify_execution
      verify_outcomes
      verify_files unless @phase == 'baseline'
      puts "Verified #{@phase}: #{@rows.size} RSpec examples; expectation counts unavailable."
      @rows.select { |row| row['status'] == 'pending' }.each do |row|
        puts "Reviewed baseline skip: #{row['id']}"
      end
    end

    private

    def validate_shape
      valid = @report['version'] == 1 && @report['framework'] == 'rspec' && report_types? && rows_valid?
      raise Failure, "#{@phase}: invalid RSpec evidence." unless valid
    end

    def report_types?
      { 'expected' => Integer, 'errors' => Integer, 'examples' => Array }.all? do |key, type|
        @report[key].is_a?(type)
      end && %w[started problems].all? { |key| strings?(@report[key]) }
    end

    def strings?(value)
      value.is_a?(Array) && value.all?(String)
    end

    def rows_valid?
      @rows.all? do |row|
        row.is_a?(Hash) && %w[id status type].all? { |key| row[key].is_a?(String) } && strings?(row['files'])
      end
    end

    def verify_execution
      raise Failure, "#{@phase}: no RSpec examples executed." if @rows.empty?
      raise Failure, "#{@phase}: RSpec suite errors." unless @report['errors'].zero?
      raise Failure, "#{@phase}: narrowed or dry-run RSpec execution." unless @report['problems'].empty?
      raise Failure, "#{@phase}: incomplete RSpec execution." unless complete?
    end

    def complete?
      ids = @rows.map { |row| row['id'] }
      @report['complete'] == true && @report['expected'] == ids.size &&
        ids.uniq.size == ids.size && @report['started'].sort == ids.sort
    end

    def verify_outcomes
      rejected = @rows.reject { |row| acceptable?(row) }
      unless rejected.empty?
        raise Failure, "#{@phase}: failed or pending RSpec examples: #{rejected.map { |row| row['id'] }.join(', ')}"
      end
      raise Failure, "#{@phase}: no passing RSpec examples." unless @rows.any? { |row| row['status'] == 'pass' }
    end

    def acceptable?(row)
      row['status'] == 'pass' || (@phase == 'baseline' && row['status'] == 'pending' &&
                                @selection.skips.include?(row['id']))
    end

    def verify_files
      type = @phase == 'caller' ? 'request' : 'system'
      @files.each do |file|
        next if @rows.any? { |row| row['files'].include?(file) && row['type'] == type }

        raise Failure, "#{@phase}: #{file} executed no RSpec #{type} examples."
      end
    end
  end
end
