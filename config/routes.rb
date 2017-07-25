Rails.application.routes.draw do
  devise_for :users
  root 'datasets#index'

  resources :datasets, only: %i(index), param: :area do
    get :defaults, on: :collection
    post :calculate

    resources :commits, only: %i(new create) do
      post :dataset_edits, on: :collection
    end
  end

  post :charts, to: "charts#data"

  namespace :api do
    namespace :v1 do
      resources :exports, only: :show, param: :area
    end
  end
end
