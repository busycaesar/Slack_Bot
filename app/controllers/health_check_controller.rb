class HealthCheckController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:index]

    def index
        begin
            ActiveRecord::Base.connection.active?
            render json: {
                status: "Okay",
                message: "App is serving. Database is connected."
            }
        rescue ActiveRecord::ConnectionNotEstablished => e
            render json: {
                state: "Error",
                message: "App is serving. Database is not connected."
            }
        end
    end
end
