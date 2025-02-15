class Incident < ApplicationRecord
    # Make sure that the title is always present.
    validates :title, presence: true
end
