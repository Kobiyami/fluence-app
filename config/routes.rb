Rails.application.routes.draw do
  get "sessions/new"
  get "sessions/start"
  get "sessions/stop"
  get "sessions/show"
  get "texts/index"
  get "texts/show"
  get "students/index"
  get "students/show"
  get "students/login_form"
  get "students/login_check"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
resources :students, only: [:index, :show]
resources :reading_texts, only: [:index, :show]

get  "/login", to: "students#login_form"
post "/login", to: "students#login_check"

resources :sessions, only: [:new, :show]
post "/sessions/start", to: "sessions#start"
post "/sessions/stop",  to: "sessions#stop"
end
