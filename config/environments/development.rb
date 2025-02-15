require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.eager_load = false

  config.hosts << 'a83d-174-91-45-102.ngrok-free.app'
end
