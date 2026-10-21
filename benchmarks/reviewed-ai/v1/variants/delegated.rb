# frozen_string_literal: true

Assistance::ExecuteResolution.singleton_class.class_eval do
  alias_method :apply_reviewed_ticket, :call
  define_method(:call) { |id, **options| apply_reviewed_ticket(id, **options) }
end
