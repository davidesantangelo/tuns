Rails.application.routes.draw do
  devise_for :users, :controllers => { omniauth_callbacks: 'users/omniauth_callbacks' }

  root 'static#index'

  resources :users do
    collection do 
      match ':id/complete' => 'users#complete', via: [:get, :patch], :as => :complete
    end
  end
end
