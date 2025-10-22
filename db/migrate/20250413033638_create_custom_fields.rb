class CreateCustomFields < ActiveRecord::Migration[7.0]
  def change
    create_table :custom_fields do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :field_type, null: false
      t.string :category, null: false
      t.json :options

      t.timestamps
    end

    add_index :custom_fields, %i[user_id category name], unique: true
  end
end
