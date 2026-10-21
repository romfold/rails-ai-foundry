# frozen_string_literal: true

Rails.application.routes.draw do
  post '/graphql', to: 'directory/graphql#create'
  get '/health', to: proc { [200, { 'content-type' => 'text/plain' }, ['directory ready']] }
end
