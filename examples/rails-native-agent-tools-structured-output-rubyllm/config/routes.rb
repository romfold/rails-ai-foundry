# frozen_string_literal: true

Rails.application.routes.draw do
  post '/answers', to: 'assistance/answers#create'
  root 'assistance/demo_sessions#new'
  get '/demo/login', to: 'assistance/demo_sessions#new', as: :demo_login
  post '/demo/login', to: 'assistance/demo_sessions#create'
  resources :resolutions, controller: 'assistance/resolutions', only: %i[index create show] do
    member do
      post :approve
      post :reject
      post :cancel
      post :retry
    end
  end
end
