Rails.application.routes.draw do
  get "portfolio_assets/create"
  get "portfolio_assets/update"
  get "portfolio_assets/destroy"
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "custom_assets#index"

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'


  resources :custom_assets

  resources :portfolios do
    resources :portfolio_assets, only: [:create, :update, :destroy]
  end  

  resources :trades

  resources :risk_analysis

  # Define the main resources for market_data
  resources :market_data, path_names: { new: 'new', edit: 'edit' } do
    collection do
      # Route for fetching historical data
      post :fetch_historical
      # Route for fetching real-time market data (existing)
      post :fetch
    end
  end

  resources :predictions

  resources :risk_metrics, only: [:index, :show, :create, :destroy]

  namespace :api do
    get 'snowflake', to: 'snowflake#index'
  end  

  resources :market_data do
    collection do
      post :fetch
    end
  end
  
end
