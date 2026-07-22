Rails.application.routes.draw do
  root "students#index"

  resources :students, only: [:index, :show]
  resources :reading_texts, only: [:index, :show]
  resources :mot_outils, only: [:index, :create, :destroy]

  get  "/login", to: "students#login_form"
  get "mots_outils/play", to: "mot_outil_exercises#play", as: :play_mot_outils
  get "mots_outils/pronounce", to: "mot_outil_exercises#pronounce"
  post "mots_outils/finish", to: "mot_outil_exercises#finish"
  post "/login", to: "students#login_check"
  post "/transcriptions", to: "transcriptions#create"

  resources :sessions, only: [:new, :show]
  post "/sessions/start", to: "sessions#start"
  post "/sessions/stop",  to: "sessions#stop"
end
