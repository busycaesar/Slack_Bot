class SlackController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:index]

    def index
        # Get the text from the request body.
        text = params[:text]
        username = params[:user_name]
        command_params = text.split

        # Get the request type.
        request_type = command_params.first

        result = ''

        if request_type == 'declare'
            # Get the title of the incident.
            incident_title = command_params.drop(1).join(" ")
            result = declare_incident(incident_title)
        else
            result = resolve_incident
        end
        
        render plain: "Hello #{username}. #{result}"
    end

    def declare_incident(title)
        return "Your incident is declared with the title, #{title}."
    end

    def resolve_incident
        return "The incident is resolved."
    end
end
