class CreateHealthLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :health_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.date :logged_on, null: false
      t.integer :mood
      t.integer :stress_level
      t.integer :fatigue_level
      t.text :notes
      t.json :custom_fields

      t.timestamps
    end

    add_index :health_logs, %i[user_id logged_on]
  end
end
