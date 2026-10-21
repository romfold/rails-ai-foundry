# frozen_string_literal: true

Rails.application.routes.draw do
  root 'voice/demos#show'
  post '/sessions', to: 'voice/sessions#create'
  post '/sessions/:id/control', to: 'voice/sessions#control'
  post '/sessions/:id/media', to: 'voice/sessions#push'
  get '/sessions/:id/media', to: 'voice/sessions#shift'
end
