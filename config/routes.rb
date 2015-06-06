require 'resque_web'

Rails.application.routes.draw do
  mount ResqueWeb::Engine => '/resque_web'
  resources :jobs
  resource :jobs, only: [:show] do
    resources :create, controller: 'jobs/create', only: [:new] do
      collection do
        post :create_videos
        patch :create_videos
      end
      member do
        get :add_information
        post :create_information
        patch :create_information
        get :add_payment
        post :create_payment
        patch :create_payment
      end
    end
  end

  root to: 'visitors#job_start'
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  namespace :api do
    namespace :v1 do
      resources :user_files, only: [:index]
    end
  end
end
