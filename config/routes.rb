Rails.application.routes.draw do
  root "students#index"

  resources :students, only: [:index, :show]
  resources :reading_texts, only: [:index, :show]

  get  "/login", to: "students#login_form"
  post "/login", to: "students#login_check"
  post "/transcriptions", to: "transcriptions#create"

  post "/sessions/start", to: "sessions#start", as: "sessions_start"
  post "/sessions/stop",  to: "sessions#stop"
  resources :sessions, only: [:show]
end