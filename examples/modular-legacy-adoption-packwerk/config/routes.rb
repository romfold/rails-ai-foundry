# frozen_string_literal: true

Rails.application.routes.draw do
  root 'billing/invoices#index'
  get '/legacy_report', to: 'legacy_reports#show'
  get '/report', to: 'reports/summaries#show'
  post '/invoices/:id/pay', to: 'billing/invoices#pay', as: :pay_invoice
end
