Rails.application.routes.draw do
  root 'home#index'

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  resources :users, only: [:new, :create, :edit, :update]
  
  namespace :admin do
    resources :moderation, only: [:index] do
      collection do
        post :batch_action
        patch :update_user
      end
    end
  end

  resources :students, only: [:index, :show]
  resources :teachers, only: [:index, :show]
  resources :subjects, only: [:create, :update, :destroy]
  resources :proposals, only: [:new, :create, :show, :update] do
    member do
      patch :accept
      patch :reject
      patch :close
      patch :counter
      patch :pay
      patch :schedule
      patch :start_session
      patch :finish_session
      patch :rate
    end
    resources :messages, only: [:create] do
      member do
        patch :answer
      end
    end
  end
  
  get '/learn', to: 'learn#index'
  get '/plan', to: 'learn#index'
  
  resources :notifications, only: [] do
    member do
      patch :read
    end
  end
  
  get "up" => "rails/health#show", as: :rails_health_check
end
