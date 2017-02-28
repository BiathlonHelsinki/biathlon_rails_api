class CreateNodes < ActiveRecord::Migration[5.0]
  def change
    create_table :nodes do |t|
      t.string :name
      t.string :slug
      t.boolean :is_open, default: false, null: false

      t.timestamps
    end
  end
end
