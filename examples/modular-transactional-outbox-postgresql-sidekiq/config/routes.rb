# frozen_string_literal: true

Rails.application.routes.draw do
  post '/orders', to: 'orders/orders#create'
  get '/orders/:id', to: 'orders/orders#show'
end
