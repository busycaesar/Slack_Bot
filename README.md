# Slack Bot

## Description
This Slack bot streamlines incident management within your organization by allowing users to report and resolve incidents through Slack's slash command. It integrates with PostgreSQL to store incident data and automatically creates dedicated channels for each reported incident. The bot also tracks the time taken by the team to resolve an incident, along with a web interface for easy access the list of incidents status.

## Tech Stack
![Image Alt](https://skillicons.dev/icons?i=rails,tailwindcss,postgres)

## Features
- **Incident Reporting**: Users can report incidents via a Slack slash command, opening a modal where they can provide details such as:
  - Title
  - Description
  - Severity
- **PostgreSQL Integration**: All incident details are stored in a PostgreSQL database for tracking and future reference.
- **Dedicated Channels**: A new Slack channel is created for each incident, making it easy for teams to collaborate and resolve issues. The bot also tracks and informs users of the time taken to resolve an incident
- **Incident Resolution**: Users can resolve incidents by issuing another Slack command within the dedicated incident channel.
- **Incident Tracking in Web UI**: A UI that allows users to view a list of incidents, including their current status. The UI supports sorting incidents by their title in ascending or descending order.

## Author
[Dev Shah](https://github.com/busycaesar)
