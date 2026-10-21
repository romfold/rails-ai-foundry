# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/mock'
require 'tmpdir'
require 'fileutils'
require 'yaml'
require 'open3'
require 'rbconfig'
require 'stringio'
require 'rails_ai_foundry'

class FoundryTest < Minitest::Test
  def setup
    @root = Dir.mktmpdir('foundry-test-')
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def write(path, content)
    target = File.join(@root, path)
    FileUtils.mkdir_p(File.dirname(target))
    File.binwrite(target, content)
  end

  def snapshot
    Dir.glob(File.join(@root, '**', '*'), File::FNM_DOTMATCH).select { |path| File.file?(path) }.to_h do |path|
      [path.delete_prefix("#{@root}/"), File.binread(path)]
    end
  end
end
