require "net/http"
require "uri"
require "json"

class SlackController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:index, :declare]

    # Get the token from the env variables.
    SLACK_BOT_TOKEN = ENV["SLACK_BOT_TOKEN"]
    
    def index
        # Get the text from the request body.
        text = params[:text]
        trigger_id = params[:trigger_id]
        username = params[:user_name]
        channel_name = params[:channel_name]
        
        # Parse the command.
        command, *title_words = text.split(" ")
        title = title_words.join(" ")

        # Make sure that the command is used properly.
        if command != 'declare' && command != 'resolve'
            render plain: "command use: /rootly declare <incident title>", status: 200
            return
        end

        if command == 'declare'
            # Make sure that the title is added for the incident.
            if title.empty?
                render plain: "please add title for the incident", status: 200
                return
            end

            # Open the modal to declare a new incident.
            response = open_modal(trigger_id, title)

            render plain: response, status: 201
            
            return
        end

        response = resolve_incident(channel_name)

        # Return the response.
        render plain: response, status: 201
    end

    def declare
        # Parse the payload string.
        payload = JSON.parse(params["payload"])
        # Get the values from the payload.
        values = payload["view"]["state"]["values"]

        # Make sure that the function is only called once the user clicks the submit button.
        if payload["type"] != "view_submission"
            render json: { response_action: "clear" }, status: 200
            return
        end

        # Separate the key and values.
        key, title_value = values.first
        key, description_value = values.to_a[1]
        key, severity_value = values.to_a[2]

        # Get the required data from the value of keys.
        title = title_value.dig("title_input-action", "value") if title_value.is_a?(Hash)
        description = description_value.dig("description_input-action", "value") if description_value.is_a?(Hash)

        # Make sure that there is a select option before trying to get the text of the selected option.
        severity = severity_value.dig("severity_select-action", "selected_option", "text", "text") if severity_value.is_a?(Hash)

        # Update the string of the title to all small case and replace spaces with "-".
        title = title.downcase.gsub(" ", "-") 

        # Store the incident data.
        incident = Incident.create(
            title: title,
            description: description || nil,
            severity: severity || nil,
            resolve: false,
            resolved_at: nil
        )

        # Respond with the necessary JSON response
        if incident.persisted?
            begin
                create_channel(title)
                render json: { response_action: "clear" }, status: 201
            rescue => e
                render json: { response_action: "errors", errors: e.message }, status: 400    
            end
        else
            render json: { response_action: "errors", errors: incident.errors.full_messages }, status: 400
        end
    end

    def list_view
        # Choose the order to sort the incidents.
        sort_order = params[:sort] == "desc" ? :desc : :asc

        # Get the incidents from the database in the choosen order.
        @incidents = Incident.order(title: sort_order)
      
        respond_to do |format|
          format.html
          format.turbo_stream
        end
      end      

    private

    def open_modal(trigger_id, title)
        uri = URI("https://slack.com/api/views.open")

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
      
        # Create a new POST request.
        request = Net::HTTP::Post.new(uri)

        # Add required data into the request object.
        request["Content-Type"] = "application/json"
        request["Authorization"] = "Bearer #{SLACK_BOT_TOKEN}"
        request.body = {
          trigger_id: trigger_id,
          view: {
            "type": "modal",
            "title": {
                "type": "plain_text",
                "text": "New Incident",
                "emoji": true
            },
            "submit": {
                "type": "plain_text",
                "text": "Create",
                "emoji": true
            },
            "close": {
                "type": "plain_text",
                "text": "Cancel",
                "emoji": true
            },
            "blocks": [
                {
                    "type": "input",
                    "element": {
                        "type": "plain_text_input",
                        "action_id": "title_input-action",
                        "initial_value": title
                    },
                    "label": {
                        "type": "plain_text",
                        "text": "Title",
                        "emoji": true
                    }
                },
                {
                    "type": "input",
                    "optional": true,
                    "element": {
                        "type": "plain_text_input",
                        "multiline": true,
                        "action_id": "description_input-action",
                    },
                    "label": {
                        "type": "plain_text",
                        "text": "Description",
                        "emoji": true
                    }
                },
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": "Severity (Optional)"
                        },
                    "accessory": {
                        "type": "static_select",
                        "placeholder": {
                            "type": "plain_text",
                            "text": "Select severity",
                            "emoji": true
                        },
                        "options": [
                            {
                                "text": {
                                    "type": "plain_text",
                                    "text": "sev0",
                                    "emoji": true
                                },
                                "value": "sev0"
                            },
                            {
                                "text": {
                                    "type": "plain_text",
                                    "text": "sev1",
                                    "emoji": true
                                },
                                "value": "sev1"
                            },
                            {
                                "text": {
                                    "type": "plain_text",
                                    "text": "sev2",
                                    "emoji": true
                                },
                                "value": "sev2"
                            }
                        ],
                        "action_id": "severity_select-action"
                    }
                }
            ]
          }
        }.to_json

        # Make the request while passing the request
        response = http.request(request)

        if response.code == '200'
            return "The incident is added. Please browse the channel \"#{title}\" and join it."
        else
            return "Failed to open the modal."
        end
    end

    # Method to create a new Slack channel
    def create_channel(title)
        # Define the Slack API URL for channel creation
        url = URI('https://slack.com/api/conversations.create')

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        
        request = Net::HTTP::Post.new(url)
        request['Content-Type'] = 'application/json'
        request['Authorization'] = "Bearer #{SLACK_BOT_TOKEN}"
    
        # Define the request body
        request.body = {
            "name" => title,
            "is_private" => false
        }.to_json
  
        # Make the request
        response = http.request(request)

        puts response.code

        if response.code != '200'
            raise "Failed to open the modal."
        end
    end

    def resolve_incident(channel_name)
        # Make sure that the request is sent from the dedicated incident channel.
        incident = Incident.find_by(title: channel_name)

        if incident.nil?
            return "please use this command from the dedicated incident channel."
        end

        begin
            # Mark the incident as resolved along with the time stamp.
            incident.update(resolve: true, resolved_at: Time.current)

            # Calculate the time taken to resolve the incident.
            time_taken_in_seconds = (Time.current - incident.created_at).to_f

            # Convert time taken to hours, minutes, and seconds
            hours = (time_taken_in_seconds / 3600).to_i
            minutes = ((time_taken_in_seconds % 3600) / 60).to_i
            seconds = (time_taken_in_seconds % 60).to_i

            # Format the time string with two digits after the decimal
            time_taken = "#{hours} hours, #{minutes} minutes, #{seconds} seconds"
    
            # Return the time taken.
            return "The incident is resolved. Time Taken: #{time_taken}."
        rescue StandardError => e
            # Handle unexpected errors
            return "Error occured while resolving the incident."
        end
    end
end
