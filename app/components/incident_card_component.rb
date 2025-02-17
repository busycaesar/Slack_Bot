class IncidentCardComponent < ViewComponent::Base
    def initialize(incident:)
        @incident = incident
    end
end
