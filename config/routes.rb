Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      resources :providers, only: [:show] do
        get 'notes', to: 'notes#index_for_provider', on: :member
      end

      resources :clients, only: [:show] do
        resources :notes, only: [:create] do
          get '/', action: :index_for_client, on: :collection
        end
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
