class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.integer :user_id
      t.date :birth_date
      t.float :height_cm
      t.float :weight_kg
      t.json :custom_fields

      t.timestamps
    end
  end
end
