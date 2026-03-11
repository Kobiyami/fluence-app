Rails.application.routes.draw do
  root "students#index"

  resources :students, only: [:index, :show]
  resources :reading_texts, only: [:index, :show]

  get  "/login", to: "students#login_form"
  post "/login", to: "students#login_check"
  post "/transcriptions", to: "transcriptions#create"

  resources :sessions, only: [:new, :show]
  post "/sessions/start", to: "sessions#start"
  post "/sessions/stop",  to: "sessions#stop"
end
