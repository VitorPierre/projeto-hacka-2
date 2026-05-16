Rails.application.routes.draw do
  root 'home#index'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users, only: [:new, :create]
  resources :students, only: [:index, :show] do
    member do
      patch :update_subjects
    end
  end
  resources :teachers, only: [:index, :show] do
    member do
      patch :update_subjects
    end
  end
  resources :proposals, only: [:new, :create, :show, :update] do
    member do
      patch :accept
      patch :reject
      patch :close
    end
    resources :messages, only: [:create]
  end
  
  get "up" => "rails/health#show", as: :rails_health_check
end
