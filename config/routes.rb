Rails.application.routes.draw do
  post "/slack/incident", to: "slack#index"
  post "/slack/declare", to: "slack#declare"
end
