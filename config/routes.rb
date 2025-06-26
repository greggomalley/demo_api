Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token


  namespace :api do
    namespace :v1 do
      resources :industries, only: [:index, :show, :create, :destroy]
      resources :leads, only: [:index, :show, :create, :destroy] do
        collection  do
          post :assign
        end
      end
      resources :users, only: [:index]
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
