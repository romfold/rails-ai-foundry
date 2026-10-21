# frozen_string_literal: true

root 'access/sessions#new'
resource :session, only: %i[create destroy], controller: 'access/sessions'
