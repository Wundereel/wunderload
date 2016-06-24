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
  get "/l/weddingvideo" => 'landing#show', as: :weddingvideo, format: false, id: 'wedding2'
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

  if ENV['ACME_KEY'] && ENV['ACME_TOKEN']
    get ".well-known/acme-challenge/#{ ENV["ACME_TOKEN"] }" => proc { [200, {}, [ ENV["ACME_KEY"] ] ] }
  else
    ENV.each do |var, _|
      next unless var.start_with?("ACME_TOKEN_")
      number = var.sub(/ACME_TOKEN_/, '')
      get ".well-known/acme-challenge/#{ ENV["ACME_TOKEN_#{number}"] }" => proc { [200, {}, [ ENV["ACME_KEY_#{number}"] ] ] }
    end
  end
end
