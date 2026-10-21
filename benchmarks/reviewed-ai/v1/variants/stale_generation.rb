# frozen_string_literal: true

Assistance::GenerateResolution.singleton_class.prepend(Module.new do
  def owned?(request, _token)
    request.state == 'generating'
  end
end)
