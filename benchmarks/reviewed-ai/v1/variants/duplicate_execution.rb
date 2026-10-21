# frozen_string_literal: true

Assistance::ExecuteResolution.singleton_class.prepend(Module.new do
  define_method(:call) do |id, **options|
    work = Assistance::ResolutionRequest.find(id)
    Assistance::Ticket.find(work.ticket_id).increment!(:lock_version) if work.state == 'completed'
    super(id, **options)
  end
end)
