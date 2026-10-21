# frozen_string_literal: true

require 'psych'

module RailsAIFoundry
  module Support
    class SafeYaml
      class Invalid < StandardError; end

      TAGS = %w[str int float bool null map seq].map { |name| "tag:yaml.org,2002:#{name}" }.freeze

      def self.load(source)
        raise Invalid, 'ERB templates are not supported; use literal YAML data.' if source.include?('<%')

        tree = Psych.parse_stream(source)
        raise Invalid, 'Expected exactly one YAML document.' unless tree.children.length == 1

        inspect_node(tree)
        Psych.safe_load(source, permitted_classes: [], permitted_symbols: [], aliases: false)
      rescue Psych::Exception => e
        location = e.respond_to?(:line) ? " at line #{e.line}" : ''
        raise Invalid, "Invalid or unsafe YAML#{location}; use primitive data without aliases or object tags."
      end

      def self.inspect_node(node)
        raise Invalid, 'YAML aliases are not supported.' if node.is_a?(Psych::Nodes::Alias)

        raise Invalid, 'Custom YAML tags are not supported.' if invalid_tag?(node)

        inspect_mapping(node) if node.is_a?(Psych::Nodes::Mapping)
        (node.children || []).each { |child| inspect_node(child) }
      end

      def self.invalid_tag?(node)
        node.respond_to?(:tag) && node.tag && !TAGS.include?(node.tag)
      end

      def self.key_value(key)
        key.quoted || key.tag == TAGS.first ? key.value : Psych.safe_load(key.value)
      end

      def self.inspect_mapping(node)
        seen = []
        node.children.each_slice(2) do |key, _value|
          raise Invalid, 'Mapping keys must be scalar values.' unless key.is_a?(Psych::Nodes::Scalar)

          inspect_node(key)
          value = key_value(key)
          if seen.include?(value)
            raise Invalid,
                  "Duplicate mapping key #{key.value.inspect} at line #{key.start_line + 1}."
          end

          seen << value
        end
      end
      private_class_method :inspect_node, :inspect_mapping, :invalid_tag?, :key_value
    end
  end
end
