class CreatePages < ActiveRecord::Migration[5.0]
  def self.up
    create_table :pages do |t|
      t.boolean :published
      t.string :slug
      t.string :image
      t.string :image_content_type
      t.integer :image_size, length: 8
      t.integer :image_height
      t.integer :image_width

      t.timestamps
    end
    Page.create_translation_table! title: :string, body: :text
  end
  
  def self.down
    drop_table :pages
    Page.drop_translation_table!
  end
  
end
