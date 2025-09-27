Rails.application.routes.draw do
  # Onboarding flow
  get "onboarding", to: "onboarding#index"
  get "onboarding/choose_role"
  post "onboarding/set_role"
  get "onboarding/complete"

  get "home/index"
  resources :messages
  resources :mentorship_requests
  resources :profiles
  devise_for :users

  # API routes for enhanced chat functionality
  namespace :api do
    # Message status endpoints
    resources :messages, only: [] do
      member do
        post :mark_read
        get :status
      end
      collection do
        post :bulk_mark_read
        post :typing
      end
    end

    # Mentorship request typing indicators
    resources :mentorship_requests, only: [] do
      member do
        post :typing, to: 'typing_indicator#update_for_request'
        get :typing, to: 'typing_indicator#get_typing_users'
      end
    end

    # Typing cleanup endpoint
    post 'typing/cleanup', to: 'typing_indicator#cleanup_expired'
  end

  # ActionCable mount
  mount ActionCable.server => '/cable'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
