# frozen_string_literal: true

require_relative 'test_helper'

class AIJourneyParityTest < FoundryTest
  def test_shipped_snippets_match_the_reviewed_source
    root = File.expand_path('..', __dir__)
    guide = File.read(File.join(root, 'docs/first-ai-feature.md'), encoding: Encoding::UTF_8)
    snippets = guide.scan(/^```\w+ file=(\S+) phase=\w+ source=(\S+)\n(.*?)^```/m)
    assert_operator snippets.length, :>=, 60
    snippets.each do |path, source, body|
      canonical = File.read(File.join(root, 'examples/rails-native-agent-tools-structured-output-rubyllm', source),
                            encoding: Encoding::UTF_8)
      canonical = canonical.sub("gem 'rails_ai_foundry', path: '../..'", "gem 'rails_ai_foundry', '1.0.0'")
      canonical = canonical.sub('    - examples/*/db/schema.rb', '    - db/schema.rb') if path == '.rubocop.yml'
      canonical = canonical.sub('spec_kit', 'none') if path == 'config/foundry.yml'
      if path == 'config/routes.rb'
        canonical = canonical.sub("  post '/answers', to: 'assistance/answers#create'\n",
                                  '')
      end
      assert_equal canonical.rstrip, body.rstrip, path
    end
  end
end
