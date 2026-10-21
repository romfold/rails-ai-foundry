# frozen_string_literal: true

require_relative 'test_helper'

class CharacterizationTest < ActionDispatch::IntegrationTest
  AUTHORIZATION = { 'Authorization' => 'Bearer demo-a' }.freeze

  test 'document HTTP lifecycle preserves revisions and explicit errors' do
    post '/documents', params: { title: 'Policy', body: 'Refund in thirty days' }, headers: AUTHORIZATION, as: :json
    assert_response :ok
    row = response.parsed_body
    assert_equal 'draft', row.fetch('status')
    assert_equal 1, row.fetch('revision')
    patch "/documents/#{row.fetch('id')}", params: { revision: 1, transition: 'publish' },
                                           headers: AUTHORIZATION, as: :json
    assert_response :ok
    assert_equal 'published', response.parsed_body.fetch('status')
    assert_equal 2, response.parsed_body.fetch('revision')
    patch "/documents/#{row.fetch('id')}", params: { revision: 1, transition: 'delete' },
                                           headers: AUTHORIZATION, as: :json
    assert_response :unprocessable_entity
    assert_equal 'conflict', response.parsed_body.fetch('error')
    patch "/documents/#{row.fetch('id')}", params: { revision: 2, transition: 'withdraw' },
                                           headers: AUTHORIZATION, as: :json
    assert_response :ok
    assert_equal 'withdrawn', response.parsed_body.fetch('status')
    patch "/documents/#{row.fetch('id')}", params: { revision: 3, transition: 'delete' },
                                           headers: AUTHORIZATION, as: :json
    assert_response :ok
    get '/documents', headers: AUTHORIZATION, as: :json
    refute_includes response.parsed_body.map { |item| item.fetch('id') }, row.fetch('id')
  end

  test 'untrusted tenant identity cannot read or modify another tenant' do
    post '/documents', params: { title: 'Private', body: 'Tenant A secret', tenant_id: 'tenant-b' },
                       headers: AUTHORIZATION, as: :json
    row = response.parsed_body
    assert_equal 'tenant-a', row.fetch('tenant_id')
    other = { 'Authorization' => 'Bearer demo-b' }
    get '/documents', headers: other, as: :json
    assert_response :ok
    refute_includes response.parsed_body.map { |item| item.fetch('id') }, row.fetch('id')
    patch "/documents/#{row.fetch('id')}", params: { revision: 1, transition: 'delete' }, headers: other, as: :json
    assert_response :unprocessable_entity
    assert_equal 'not_found', response.parsed_body.fetch('error')
    get '/documents', as: :json
    assert_response :unauthorized
  end

  test 'validation and failed operation preserve database contents' do
    post '/documents', params: { title: '', body: 'Invalid' }, headers: AUTHORIZATION, as: :json
    assert_response :unprocessable_entity
    assert_equal 'invalid_content', response.parsed_body.fetch('error')
    principal = Access::Identity.authenticate('demo-a')
    before = Rails.configuration.x.knowledge.list(principal: principal)
    result = Rails.configuration.x.knowledge.change(
      principal: principal, action: 'create', attributes: { title: 'Rollback', body: 'Never stored' },
      after_write: -> { Dry::Monads::Failure(:declined) }
    )
    assert_equal :declined, result.failure
    assert_equal before, Rails.configuration.x.knowledge.list(principal: principal)
  end

  test 'ordinary Rails delivery loads views and session authentication' do
    get '/'
    assert_response :ok
    assert_select 'form'
    post '/session', params: { token: 'demo-a' }
    assert_response :see_other
    follow_redirect!
    assert_response :ok
    assert_select 'h1', text: /Knowledge/
  end
end
