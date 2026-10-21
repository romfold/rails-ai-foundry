# frozen_string_literal: true

require_relative '../test_helper'
control = ARGV.shift
case control
when 'bypass_approval'
  Assistance::ExecuteResolution.singleton_class.prepend(Module.new do
    define_method(:call) do |id, **options|
      work = Assistance::ResolutionRequest.find(id)
      work.update!(state: 'approved', approver_id: Assistance::User.find_by!(can_close: true).id)
      super(id, **options)
    end
  end)
when 'ignore_revision'
  Assistance::ResolutionAccess.singleton_class.prepend(Module.new do
    def current?(request, ticket, users)
      authorized?(users[request.requester_id], request.tenant) && ticket.status == 'open'
    end
  end)
when 'stale_generation'
  Assistance::GenerateResolution.singleton_class.prepend(Module.new do
    def owned?(request, _token)
      request.state == 'generating'
    end
  end)
when 'duplicate_execution'
  Assistance::ExecuteResolution.singleton_class.prepend(Module.new do
    define_method(:call) do |id, **options|
      work = Assistance::ResolutionRequest.find(id)
      Assistance::Ticket.find(work.ticket_id).increment!(:lock_version) if work.state == 'completed'
      super(id, **options)
    end
  end)
when 'valid_delegated'
  Assistance::ExecuteResolution.singleton_class.class_eval do
    alias_method :apply_reviewed_ticket, :call
    define_method(:call) { |id, **options| apply_reviewed_ticket(id, **options) }
  end
when 'valid'
  # The same behavioral tests accept direct services and their native job callers.
else
  abort 'Unknown control'
end
require_relative '../resolutions_test'
