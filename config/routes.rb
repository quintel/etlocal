Rails.application.routes.draw do
  devise_for :users
  root 'datasets#index'

  resources :datasets, only: %i(index edit show) do
    get :defaults, :download

    post :clone

    resources :commits, only: %i(create) do
      post :dataset_edits, on: :collection
    end
  end

  post :charts, to: "charts#data"

  namespace :api do
    namespace :v1 do
      resources :exports, only: :show
    end
  end
end
