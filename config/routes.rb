Rails.application.routes.draw do
  resources :jobs
  root to: 'visitors#job_start'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
end
