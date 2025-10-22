class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :age
      t.decimal :height_cm, precision: 5, scale: 2
      t.decimal :weight_kg, precision: 5, scale: 2
      t.json :custom_fields

      t.timestamps
    end

    add_index :profiles, :user_id, unique: true
  end
end
