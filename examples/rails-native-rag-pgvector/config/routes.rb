# frozen_string_literal: true

Rails.application.routes.draw do
  post '/documents', to: 'knowledge/documents#create'
  delete '/documents/:id', to: 'knowledge/documents#destroy'
  get '/answer', to: 'knowledge/documents#answer'
  get '/search', to: 'knowledge/documents#search'
end
