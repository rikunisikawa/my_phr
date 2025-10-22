Rails.application.routes.draw do
  devise_for :users

  resource :profile, only: %i[show edit update]
  resources :health_records
  get "summaries", to: "summaries#index"

  root "home#index"

  namespace :api do
    namespace :v1 do
      resource :profile, only: %i[show create update], controller: :profiles
      resources :custom_fields
      resources :health_logs do
        resources :activity_logs, only: %i[create update destroy]
      end
      get "summaries", to: "summaries#show"
    end
  end
end
