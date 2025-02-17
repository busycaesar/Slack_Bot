Rails.application.routes.draw do
  # API Routes
  post "/api/slack/incident", to: "slack#index"
  post "/api/slack/declare", to: "slack#declare"
  get "/api", to: "health_check#index"

  # Screen Routes
  get "/slack/incident-list", to: "slack#list_view"
end
