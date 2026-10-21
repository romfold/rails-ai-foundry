# frozen_string_literal: true

require 'digest'
require 'fileutils'
require 'json'
require 'open3'
require 'pathname'
require 'shellwords'
require 'timeout'
require 'yaml'
require 'lemans'

module BenchmarkSuite
  ROOT = Pathname.new(__dir__).join('../..').realpath
  REPOSITORY = ROOT.parent
  LEMANS_REVISION = '2d0b7fb8d3b0077574dcf7b70fd4e32c8f9d6e76'
  UPSTREAM_REVISION = '5327efe54dd767d662ab89332f6a4285fef07bd8'

  class Failure < StandardError; end

  module Support
    module_function

    def run(*argv, directory: Dir.pwd, timeout: 1800, check: true, stdin_data: nil)
      puts Shellwords.join(argv)
      output, status = capture(argv, directory, timeout, stdin_data)
      filtered = Lemans::SecretsFilter.default.filter(output)
      puts filtered
      result = { 'exit_code' => status&.exitstatus || 124, 'output' => filtered }
      raise Failure, "Command failed (#{result['exit_code']}): #{argv.first}" if check && result['exit_code'] != 0

      result
    end

    def capture(argv, directory, timeout, stdin_data)
      output = +''
      status = nil
      Open3.popen2e(*argv, chdir: directory, pgroup: true) do |input, stream, process|
        writer = Thread.new do
          input.write(stdin_data) if stdin_data
          input.close
        end
        reader = Thread.new { output << stream.read }
        status = wait(process, timeout)
        writer.join
        reader.join
      end
      [output, status]
    end

    def wait(process, timeout)
      Timeout.timeout(timeout) { process.value }
    rescue Timeout::Error
      Process.kill('KILL', -process.pid)
      process.value
      nil
    end

    def files(root)
      root = Pathname(root)
      paths = root.glob('**/*', File::FNM_DOTMATCH).reject do |path|
        path.relative_path_from(root).each_filename.include?('.git')
      end
      paths.sort.filter_map { |path| file_hash(root, path) }.to_h
    end

    def file_hash(root, path)
      raise Failure, "Symlink prohibited: #{path}" if path.symlink?
      return unless path.file?

      [path.relative_path_from(root).to_s, Digest::SHA256.file(path).hexdigest]
    end

    def json(path, data)
      text = Lemans::SecretsFilter.default.filter("#{JSON.pretty_generate(data)}\n")
      File.open(path, File::WRONLY | File::CREAT | File::EXCL, 0o600) { |file| file.write(text) }
    end

    def external_directory(path)
      path = Pathname(path).expand_path
      ancestor = path
      ancestor = ancestor.parent until ancestor.exist?
      resolved = ancestor.realpath.join(path.relative_path_from(ancestor)).cleanpath
      if resolved == REPOSITORY || resolved.to_s.start_with?("#{REPOSITORY}/")
        raise Failure, 'Use a task-owned output directory outside the Foundry repository'
      end
      raise Failure, "Refusing existing output: #{resolved}" if resolved.exist?

      resolved.mkpath
      resolved
    end

    def docker(*argv, **options)
      run('docker', *argv, **options)
    end
  end
end
