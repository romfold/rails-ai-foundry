# frozen_string_literal: true

Assistance::ResolutionAccess.singleton_class.prepend(Module.new do
  def current?(request, ticket, users)
    authorized?(users[request.requester_id], request.tenant) && ticket.status == 'open'
  end
end)
