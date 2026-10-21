#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'rbconfig'
require 'shellwords'
require 'tmpdir'

source = File.expand_path('..', __dir__)
controls = {
  'reference' => nil,
  'equivalent-copy-check' => ['audit_snapshot',
                              'expected == self.class.new(directory).inventory && expected == inventory',
                              'expected == inventory && expected == self.class.new(directory).inventory'],
  'private-copy' => ['audit_snapshot', '.agents .claude .codex', '.agents .codex'],
  'excluded-debt' => ['debt', "snapshot.paths.select { |path| File.basename(path) == 'package_todo.yml' }",
                      "Dir.glob('**/package_todo.yml', File::FNM_DOTMATCH, base: root).sort"],
  'live-recapture' => ['debt_audit', 'identities = captured.copy do |directory|',
                       'identities = snapshot.copy do |directory|'],
  'unchecked-copy' => ['audit_snapshot', 'expected == self.class.new(directory).inventory && expected == inventory',
                       'expected == inventory']
}

controls.each do |name, mutation|
  Dir.mktmpdir('foundry-audit-control-') do |root|
    FileUtils.cp_r(File.join(source, 'lib'), root)
    FileUtils.mkdir_p(File.join(root, 'test'))
    %w[test_helper.rb audit_snapshot_test.rb audit_capture_test.rb].each do |file|
      FileUtils.cp(File.join(source, 'test', file), File.join(root, 'test', file))
    end
    if mutation
      file, before, after = mutation
      path = File.join(root, 'lib/rails_ai_foundry/conventions', "#{file}.rb")
      content = File.read(path)
      raise "Control no longer matches: #{name}" unless content.include?(before)

      File.write(path, content.sub(before, after))
    end
    argv = [RbConfig.ruby, "-I#{root}/lib", "-I#{root}/test", '-e',
            'ARGV.each { |file| require file }', "#{root}/test/audit_snapshot_test.rb",
            "#{root}/test/audit_capture_test.rb"]
    puts "#{name}: #{argv.shelljoin}"
    output, error, status = Open3.capture3(*argv, chdir: root)
    puts output
    warn error unless error.empty?
    valid = %w[reference equivalent-copy-check].include?(name)
    raise "Unexpected control outcome: #{name}" unless status.success? == valid
    raise "Control did not reach assertions: #{name}" unless output.match?(/\d+ runs, [1-9]\d* assertions/)
  end
end
puts 'Audit controls passed: two valid implementations, four rejected faults.'
