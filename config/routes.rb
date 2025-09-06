Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by uptime monitors and load balancers.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "dashboard#index"

  # API routes
  namespace :api do
    namespace :v1 do
      # Lottery data endpoints
      resources :lottery_draws, only: [:index, :show]
      resources :predictions, only: [:index, :show]
      resources :template_predictions, only: [:index, :show]
      
      # Statistical analysis endpoints
      resources :day_of_week_summaries, only: [:index, :show]
      resources :month_summaries, only: [:index, :show]
      resources :day_of_month_summaries, only: [:index, :show]
      resources :even_odd_summaries, only: [:index, :show]
      
      # Game-specific endpoints
      get 'vietlot45/draws', to: 'lottery_draws#vietlot45'
      get 'vietlot55/draws', to: 'lottery_draws#vietlot55'
      get 'vietlot45/predictions', to: 'predictions#vietlot45'
      get 'vietlot55/predictions', to: 'predictions#vietlot55'
    end
  end

  # Web interface routes
  get 'dashboard', to: 'dashboard#index'
  get 'vietlot45', to: 'dashboard#vietlot45'
  get 'vietlot55', to: 'dashboard#vietlot55'
  get 'statistics', to: 'dashboard#statistics'
  get 'predictions', to: 'dashboard#predictions'
  
  # Sync routes
  get 'sync', to: 'sync#index'
  post 'sync/manual', to: 'sync#manual_sync', as: 'manual_sync'
  post 'sync/force', to: 'sync#force_sync', as: 'force_sync'
  get 'sync/status', to: 'sync#sync_status', as: 'sync_status'
end
