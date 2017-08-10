class CreateUserphotos < ActiveRecord::Migration[5.0]
  def change
    create_table :userphotos do |t|
      t.string :image
      t.integer :image_file_size, length: 8
      t.string :image_content_type
      t.integer :image_width
      t.integer :image_height
      t.references :instance, foreign_key: true
      t.references :user, foreign_key: true
      t.string :credit, limit: 100
      t.string :caption, limit: 100

      t.timestamps
    end
  end
end
