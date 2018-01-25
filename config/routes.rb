Rails.application.routes.draw do
  devise_for :users
  root 'datasets#index'

  resources :datasets, only: %i(index edit), param: :area do
    get :defaults, :download

    resources :commits, only: %i(create) do
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
