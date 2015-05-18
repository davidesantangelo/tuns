Rails.application.routes.draw do
	require 'sidekiq/web'
	mount Sidekiq::Web => '/sidekiq'

  devise_for :users, :controllers => { omniauth_callbacks: 'users/omniauth_callbacks' }

  root 'static#index'

  resources :users, :path => "/" do
    collection do 
      match ':id/complete' => 'users#complete', via: [:get, :patch], :as => :complete
      match ':id/unfollowers' => 'users#unfollowers', via: [:get], :as => :unfollowers
    end
  end
end
