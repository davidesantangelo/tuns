# frozen_string_literal: true

Rails.application.routes.draw do
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'users/sessions' }, skip: [:registrations]

  root 'static#index'
  get '/about' => 'static#about', :as => :about
  get '/thanks' => 'static#thanks', :as => :thanks
  get '/feedbacks' => 'static#feedbacks', :as => :feedbacks
  get '/privacy' => 'static#privacy', :as => :privacy

  resources :users, path: '/' do
    collection do
      match ':id/complete' => 'users#complete', via: %i[get patch], :as => :complete
      get 'loadmore' => 'users#loadmore'
      get ':id/donate' => 'users#donate', :as => :donate
      get 'stats' => 'users#stats', :as => :stats
      get 'loadstats' => 'users#loadstats'
    end
  end
end
