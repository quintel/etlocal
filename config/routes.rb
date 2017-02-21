Rails.application.routes.draw do
  devise_for :users
  root 'datasets#index'

  resources :datasets, only: %i(index show), param: :area do
    resources :dataset_edits, only: %i(edit update), param: :attribute_name
  end
end
