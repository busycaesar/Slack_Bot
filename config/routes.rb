Rails.application.routes.draw do
  post "/slack/incident", to: "slack#index"
  post "/slack/declare", to: "slack#declare"
  get "/slack/incident-list", to: "slack#list_view"
  get "/app", to: "health_check#index"
end
