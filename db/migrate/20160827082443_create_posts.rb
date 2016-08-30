class CreatePosts < ActiveRecord::Migration[5.0]
  def self.up
    create_table :posts do |t|
      t.string :slug
      t.boolean :published
      t.references :user, foreign_key: true
      t.datetime :published_at
      t.string :image
      t.integer :image_width
      t.integer :image_height
      t.string :image_content_type
      t.integer :image_size, length: 8
      t.timestamps
    end
    Post.create_translation_table! title: :string, body: :text
  end
  
  def self.down
    drop_table :posts
    Post.drop_translation_table!
  end
end
