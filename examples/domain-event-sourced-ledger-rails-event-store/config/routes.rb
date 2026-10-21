# frozen_string_literal: true

Rails.application.routes.draw do
  get '/accounts/:id', to: 'ledger/accounts#show', constraints: { id: /[a-zA-Z0-9_-]+/ }
  post '/accounts/:id', to: 'ledger/accounts#create', constraints: { id: /[a-zA-Z0-9_-]+/ }
end
