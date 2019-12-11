SnitchReporting::Engine.routes.draw do
  root to: "snitch_reports#index"
  resources :snitch_reports, only: [:index, :show, :update, :edit]
end
