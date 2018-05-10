Rails.application.routes.draw do
  devise_for :users
  root 'datasets#index'

  resources :datasets, only: %i(index edit show) do
    get :download

    post :clone

    resources :commits, only: %i(create) do
      post :dataset_edits, on: :collection
    end

    get 'sandbox', to: 'sandbox#index', as: :dataset_sandbox
    post 'sandbox', to: 'sandbox#execute'
  end

  post :charts, to: "charts#data"

  namespace :api do
    namespace :v1 do
      resources :exports, only: :show
    end
  end
end
