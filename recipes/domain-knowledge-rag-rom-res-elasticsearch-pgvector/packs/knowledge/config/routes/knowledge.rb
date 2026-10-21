# frozen_string_literal: true

resources :documents, only: %i[index create update], controller: 'knowledge/documents'
