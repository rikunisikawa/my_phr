class ConvertLoggedOnToRecordedAtInHealthLogs < ActiveRecord::Migration[7.0]
  def up
    add_column :health_logs, :recorded_at, :datetime

    execute <<~SQL.squish
      UPDATE health_logs
      SET recorded_at = logged_on
    SQL

    change_column_null :health_logs, :recorded_at, false
    add_index :health_logs, %i[user_id recorded_at]

    remove_index :health_logs, name: "index_health_logs_on_user_id_and_logged_on"
    remove_column :health_logs, :logged_on
  end

  def down
    add_column :health_logs, :logged_on, :date

    execute <<~SQL.squish
      UPDATE health_logs
      SET logged_on = DATE(recorded_at)
    SQL

    change_column_null :health_logs, :logged_on, false
    add_index :health_logs, %i[user_id logged_on]

    remove_index :health_logs, column: %i[user_id recorded_at]
    remove_column :health_logs, :recorded_at
  end
end
