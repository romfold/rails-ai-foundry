# frozen_string_literal: true

Rails.application.routes.draw do
  get '/streams/:id', to: 'pipeline/cursors#show'
end
