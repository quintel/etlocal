Rails.application.routes.draw do
  devise_for :users
  root 'datasets#index'

  resources :datasets, only: %i(index show), param: :area do
    resources :dataset_edits, only: %i(edit update), param: :attribute_name
  end

  post :charts, to: "charts#data"
  post :search, to: "search#search"

  namespace :api do
    namespace :v1 do
      resources :exports, only: :show, param: :area
    end
  end
end
