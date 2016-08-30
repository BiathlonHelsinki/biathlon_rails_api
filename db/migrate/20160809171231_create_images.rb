class CreateImages < ActiveRecord::Migration[5.0]
  def change
    create_table :images do |t|
      t.string :image
      t.string :image_content_type
      t.integer :image_size, length: 8
      t.integer :image_width
      t.integer :image_height
      t.references :item, polymorphic: true
      t.timestamps
    end
  end
end
