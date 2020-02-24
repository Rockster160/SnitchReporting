SnitchReporting::Engine.routes.draw do
  root to: "snitch_reports#index"

  resources :snitch_reports, path: "/", only: [:index, :show, :update, :edit]
  post :interpret_search, controller: :snitch_reports
end
