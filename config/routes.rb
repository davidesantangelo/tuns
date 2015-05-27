Rails.application.routes.draw do
	require 'sidekiq/web'
	mount Sidekiq::Web => '/sidekiq'

  devise_for :users, :controllers => { omniauth_callbacks: 'users/omniauth_callbacks', sessions: 'users/sessions' }, :skip => [:registrations]

  root 'static#index'
  get '/about' => 'static#about', :as => :about
  get '/thanks' => 'static#thanks', :as => :thanks

  resources :users, :path => "/" do
    collection do 
      match 'complete' => 'users#complete', via: [:get, :patch], :as => :complete
      match 'loadmore' => 'users#loadmore', via: [:get]
      match ':id/donate' => 'users#donate', via: [:get], :as => :donate
    end
  end
end
