# frozen_string_literal: true

Rails.application.routes.draw do
  root 'conversations/chats#index'
  post '/chats', to: 'conversations/chats#create'
  get '/chats/:id', to: 'conversations/chats#show'
  post '/chats/:id/reply', to: 'conversations/chats#reply'
end
