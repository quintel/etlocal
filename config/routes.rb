Rails.application.routes.draw do
  root 'datasets#index'

  resources :datasets, except: :new
end
