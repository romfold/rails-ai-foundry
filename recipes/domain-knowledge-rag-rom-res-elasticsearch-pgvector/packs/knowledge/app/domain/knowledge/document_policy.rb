# frozen_string_literal: true

module Knowledge
  class DocumentPolicy
    ACTIONS = %w[edit publish withdraw delete].freeze

    def self.error(document, action, expected_revision, attributes)
      return :not_found if !document || document[:status] == 'deleted'
      return :conflict unless document[:revision] == expected_revision
      return :invalid_action unless ACTIONS.include?(action)

      transition_error(document, action, attributes)
    end

    def self.transition_error(document, action, attributes)
      return :invalid_content if action == 'edit' && !valid_content?(attributes)
      return :invalid_transition if action == 'publish' && document[:status] == 'published'
      return :invalid_transition if action == 'withdraw' && document[:status] != 'published'

      nil
    end

    def self.valid_content?(attributes)
      %i[title body].all? { |key| attributes[key].is_a?(String) && !attributes[key].strip.empty? }
    end
  end
end
