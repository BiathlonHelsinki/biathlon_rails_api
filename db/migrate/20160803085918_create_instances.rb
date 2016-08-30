class CreateInstances < ActiveRecord::Migration[5.0]
  def self.up
    create_table :instances do |t|
      t.references :event, foreign_key: true, null: false
      t.integer :cost_bb
      t.float :cost_euros

      t.datetime :start_at
      t.datetime :end_at
      t.references :place, foreign_key: true
      t.boolean :published
      t.string :image
      t.string :image_content_type
      t.integer :image_height
      t.integer :image_width
      t.integer :image_size, length: 8
      t.string :slug

      t.timestamps
    end
    Instance.create_translation_table! name: :string, description: :text
  end
  
  def self.down
    drop_table :instances
    Instance.drop_translation_table!
  end
end
