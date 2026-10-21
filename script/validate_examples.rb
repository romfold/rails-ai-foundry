#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'
require 'yaml'

class ExampleCatalog
  def self.validate(root)
    root = Pathname.new(root).realpath
    entries = YAML.safe_load_file(root.join('catalog.yml'))
    raise 'Catalog must be an array' unless entries.is_a?(Array)

    locations = entries.map { |entry| validate_entry(root, entry) }
    raise 'Duplicate example locations' unless locations.uniq == locations

    locations
  end

  def self.validate_entry(root, entry)
    validate_shape(entry)
    app = descendant(root, entry.fetch('location'))
    context = descendant(app, entry.fetch('focal_context'))

    validate_profile(app, context)
    link = "#{entry.fetch('focal_context')}/foundry.yml"
    raise "#{app}: README must link to #{link}" unless app.join('README.md').read.include?("](#{link})")

    entry.fetch('location')
  end

  def self.descendant(root, relative)
    path = root.join(relative).realpath
    raise "#{relative} escapes #{root}" unless path.to_s.start_with?("#{root}/")

    path
  end

  def self.validate_shape(entry)
    unless entry.is_a?(Hash) && entry.keys.sort == %w[focal_context location] &&
           entry.values.all? { |value| value.is_a?(String) && value.match?(%r{\A[a-z0-9_/-]+\z}) }
      raise 'Catalog entries require only location and focal_context paths'
    end
  end

  def self.validate_profile(app, context)
    profile = YAML.safe_load_file(context.join('foundry.yml')).fetch('profile')
    return if %w[rails_native modular domain].include?(profile) &&
              app.basename.to_s.start_with?("#{profile.tr('_', '-')}-")

    raise "#{app.basename}: name does not match focal profile #{profile}"
  end

  private_class_method :validate_entry, :validate_shape, :validate_profile, :descendant
end

if $PROGRAM_NAME == __FILE__
  examples = ExampleCatalog.validate(File.expand_path('../examples', __dir__))
  puts "Validated #{examples.length} executable examples: #{examples.join(', ')}"
end
