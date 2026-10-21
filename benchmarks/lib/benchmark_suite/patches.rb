# frozen_string_literal: true

require 'tmpdir'
require_relative 'corpus'
require_relative 'delivery_variants'

module BenchmarkSuite
  module Patches
    module_function

    def write(directory, task, group, solution, filename:)
      Dir.mktmpdir('foundry-patch-') do |temporary|
        work = baseline(directory, temporary)
        target = replacement(temporary, task, group, solution)
        replace_tree(work, target)
        Support.run('git', '-C', work.to_s, 'add', '-A')
        result = Support.run('git', '-C', work.to_s, 'diff', '--cached', '--binary')
        directory.join(filename).write(result.fetch('output'))
      end
    end

    def replace_tree(work, target)
      work.children.reject { |path| path.basename.to_s == '.git' }.each { |path| FileUtils.rm_rf(path) }
      FileUtils.cp_r(target.children, work)
    end

    def baseline(directory, temporary)
      work = Pathname(temporary).join('candidate')
      FileUtils.cp_r(directory.join('environment/candidate'), work)
      Support.run('git', 'init', '-q', work.to_s)
      Support.run('git', '-C', work.to_s, 'add', '.')
      Support.run('git', '-C', work.to_s, '-c', 'user.name=Benchmark', '-c',
                  'user.email=benchmark@example.invalid', 'commit', '-qm', 'Baseline')
      work
    end

    def replacement(temporary, task, group, solution)
      variant = DeliveryVariants::NAMES.include?(solution)
      target = Corpus.materialize(Pathname(temporary).join('solution'), task, group,
                                  solution: variant ? 'reference' : solution)
      DeliveryVariants.apply(target, group, solution) if variant
      target
    end
  end
end
