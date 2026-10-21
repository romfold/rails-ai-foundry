# frozen_string_literal: true

require 'open3'

module PrivacyCheck
  PATTERNS = {
    'workstation_path' => %r{(?<!/redacted)/(?:Users|home)/[^/\s"'\\]+/|/(?:private/)?var/folders/[^/\s]+/},
    'windows_home' => /[A-Za-z]:\\(?:Users|Documents and Settings)\\[^\\\s]+\\/,
    'private_key' => /-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----/,
    'provider_token' => /\b(?:sk-(?:proj-|or-v1-|ant-)?[A-Za-z0-9_-]{20,}|github_pat_\w{20,}|gh[pousr]_\w{20,})\b/,
    'aws_access_key' => /\bAKIA[A-Z0-9]{16}\b/,
    'service_token' => /\b(?:xox[baprs]-[A-Za-z0-9-]{15,}|AIza[\w-]{30,}|glpat-[\w-]{15,})\b/,
    'bearer' => /Bearer\s+[A-Za-z0-9_.-]{20,}/i,
    'jwt' => /\beyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{10,}\b/
  }.freeze

  def self.findings(content)
    content.each_line.with_index(1).flat_map do |line, number|
      PATTERNS.filter_map { |category, pattern| [number, category] if pattern.match?(line) }
    end
  end

  def self.clean?(root, output: $stdout)
    files, _error, status = Open3.capture3('git', '-C', root, 'ls-files', '--cached', '--others',
                                           '--exclude-standard', '-z')
    raise "Cannot inventory repository (status #{status.exitstatus})" unless status.success?

    count = files.split("\0").sum { |relative| scan_file(root, relative, output) }
    output.puts "Privacy check: #{count} findings (values omitted)."
    count.zero?
  end

  def self.scan_file(root, relative, output)
    path = File.join(root, relative)
    return 0 unless File.file?(path) && !File.symlink?(path)

    content = File.binread(path).force_encoding(Encoding::UTF_8)
    return 0 unless content.valid_encoding?

    matches = findings(content)
    matches.each { |line, category| output.puts "#{relative}:#{line}: #{category}" }
    matches.length
  end
end

exit(PrivacyCheck.clean?(File.expand_path('..', __dir__)) ? 0 : 1) if $PROGRAM_NAME == __FILE__
