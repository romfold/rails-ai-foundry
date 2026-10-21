# frozen_string_literal: true

Rails.application.routes.draw do
  post '/products', to: 'catalog/products#create'
  get '/products', to: 'catalog/products#index'
end
