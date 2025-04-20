class CreateCustomFieldDefinitions < ActiveRecord::Migration[7.0]
  def change
    create_table :custom_field_definitions do |t|
      t.integer :user_id
      t.string :name
      t.string :field_type

      t.timestamps
    end
    add_index :custom_field_definitions, :user_id
  end
end
