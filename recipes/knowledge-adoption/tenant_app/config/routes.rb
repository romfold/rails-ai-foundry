# frozen_string_literal: true

Rails.application.routes.draw do
  resources :documents, only: %i[index create update destroy], controller: 'knowledge/documents'
end
