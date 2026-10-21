# frozen_string_literal: true

Rails.application.routes.draw do
  get '/documents', to: 'documents#index'
end
