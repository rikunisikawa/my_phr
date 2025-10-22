class CreateActivityLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :activity_logs do |t|
      t.references :health_log, null: false, foreign_key: true
      t.string :activity_type
      t.integer :duration_minutes
      t.string :intensity
      t.json :custom_fields

      t.timestamps
    end
  end
end
