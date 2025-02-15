class AddResolvedAtToIncidents < ActiveRecord::Migration[8.0]
  def change
    add_column :incidents, :resolved_at, :datetime
  end
end
