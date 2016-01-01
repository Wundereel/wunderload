require 'resque_web'

Rails.application.routes.draw do
  mount ResqueWeb::Engine => '/resque_web'
  resources :jobs
  resource :jobs, only: [:show] do
    resources :create, controller: 'jobs/create', only: [:new] do
      collection do
        post :create_videos
        patch :create_videos
        get 'start', to: 'visitors#job_start', as: 'start'
      end
      member do
        get :new
        get :add_information
        post :create_information
        patch :create_information
        get :add_payment
        post :create_payment
        patch :create_payment
      end
    end
  end

  resources :interested_people, only: [:new, :create] do
    collection do
      get :success
      get :wedding_success
    end
  end

  authenticated :user do
    get '/db_thumb/*filepath', to: 'dropbox_thumb#get', as: 'db_thumb', :constraints => { :filepath => /.*/ }
  end

  get '/home', to: 'visitors#home', as: 'home'
  get '/interested_signup', to: 'visitors#email_signup', as: 'email_signup_success'
  get "/l/*id" => 'landing#show', as: :landing, format: false

  root to: 'visitors#home'
  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  namespace :api do
    namespace :v1 do
      resources :user_files, only: [:index]
    end
  end
end
