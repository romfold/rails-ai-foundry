# frozen_string_literal: true

Rails.application.routes.draw do
  root 'access/sessions#new'
  resource :session, only: %i[create destroy], controller: 'access/sessions'
  resources :documents, only: %i[index create update], controller: 'knowledge/documents'
end
