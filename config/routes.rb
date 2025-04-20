Rails.application.routes.draw do
  devise_for :users
  resources :profiles     # プロフィール
  resources :health_records do
    resources :exercise_logs, only: [:create, :update, :destroy]
    collection do
      get :summary  # /health_records/summary => summary表示
    end
  end

  # rootパスを健康記録の一覧などへ設定
  root "health_records#index"
end
