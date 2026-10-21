# frozen_string_literal: true

require_relative 'study_outcome'

module BenchmarkSuite
  class StudyResults
    def initialize(root)
      @root = Pathname(root).realpath
    end

    def records
      Study.attempts.map { |row| row.merge(read(row)) }
    end

    private

    def read(row)
      directory = @root.join('results', row['id'])
      paths = directory.glob('**/result.json')
      return { 'status' => directory.exist? ? 'infrastructure_error' : 'unstarted' } if paths.empty?
      raise Failure, 'Duplicate native attempts' unless paths.size == 1

      native_record(paths.first, row).merge(verification(row, directory))
    rescue Failure, KeyError, JSON::ParserError => e
      { 'status' => 'infrastructure_error', 'reason' => e.class.name }
    end

    def native_record(path, row)
      native = JSON.parse(path.read)
      raise Failure, 'Malformed native result' unless native.is_a?(Hash)
      raise Failure, 'Unexpected native identity' unless StudyOutcome.valid_identity?(native, row, @root)

      { 'native' => native, 'native_result' => path.to_s,
        'native_sha256' => Digest::SHA256.file(path).hexdigest }
    end

    def verification(row, directory)
      summary = @root.join('verification', row['id'], 'summary.json')
      return { 'status' => 'verification_pending' } unless summary.file?

      data = JSON.parse(summary.read)
      raise Failure, 'Malformed independent summary' unless data.is_a?(Hash)
      unless data['native_files'] == Support.files(directory)
        raise Failure,
              'Native artifacts changed after verification'
      end

      record = single_record(data, row)
      { 'status' => record.fetch('status'), 'verification' => record,
        'verification_sha256' => Digest::SHA256.file(summary).hexdigest }
    end

    def single_record(data, row)
      records = data.fetch('records')
      unless records.is_a?(Array) && records.size == 1 &&
             records.first.is_a?(Hash) && records.first['task'] == row['task']
        raise Failure, 'Unexpected independent records'
      end

      records.first
    end
  end
end
