class CreateHealthRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :health_records do |t|
      t.integer :user_id
      t.date :date
      t.integer :mood
      t.integer :stress
      t.integer :fatigue
      t.integer :sleep_duration
      t.integer :sleep_quality
      t.text :memo
      t.json :custom_fields

      t.timestamps
    end
  end
end
