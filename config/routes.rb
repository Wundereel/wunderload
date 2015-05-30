Rails.application.routes.draw do
  resources :jobs
  root to: 'visitors#job_start'
  devise_for :users, :controllers => {
    :omniauth_callbacks => "users/omniauth_callbacks"
  }
  namespace :api do
    namespace :v1 do
      resources :user_files, only: [:index]
    end
  end
end
