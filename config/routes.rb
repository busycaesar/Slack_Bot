Rails.application.routes.draw do
  post "/slack/incident", to: "slack#index"
end
