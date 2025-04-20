class CreateExerciseLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :exercise_logs do |t|
      t.integer :health_record_id
      t.string :activity_type
      t.integer :duration
      t.float :distance
      t.text :memo

      t.timestamps
    end
  end
end
