class CreateIncidents < ActiveRecord::Migration[8.0]
  def change
    create_table :incidents do |t|
      t.string :title, null: false
      t.text :description, null: true # Optional
      t.string :severity, null: true # Optional
      t.boolean :resolve, default: false, null: false

      t.timestamps
    end
  end
end
