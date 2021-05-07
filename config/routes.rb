Rails.application.routes.draw do
  devise_for :users
  root 'datasets#index'

  resources :datasets, only: %i(index edit show) do
    get :download

    get :not_found, on: :collection
    get :search, on: :collection

    post :clone

    member do
      get(
        'files/:interface_element_key/*file_key',
        to: 'datasets#git_file_info',
        format: false,
        as: :git_file_info
      )
    end

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

  put '/set_locale(/:locale)' => 'pages#set_new_locale', as: :set_locale
  get '/introduction' => 'pages#introduction'
end
