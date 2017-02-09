Rails.application.routes.draw do
  devise_for :users
  root 'datasets#index'

  resources :datasets, except: :new
end
