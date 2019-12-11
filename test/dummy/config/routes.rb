Rails.application.routes.draw do
  mount SnitchReporting::Engine, at: "/snitches"
end
