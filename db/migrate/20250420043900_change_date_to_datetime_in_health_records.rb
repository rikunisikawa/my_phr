class ChangeDateToDatetimeInHealthRecords < ActiveRecord::Migration[7.0]
  def change
    change_column :health_records, :date, :datetime
  end
end
