# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tenant screen', type: :request do
  it 'conceals another tenant and permits the authorized caller' do
    get '/screen', params: { identity: 'foreign' }
    expect(response).to have_http_status(:not_found)
    get '/screen', params: { identity: 'reader' }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Draft')
  end
end
