class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.references :item, polymorphic: true
      t.references :user, foreign_key: true
      t.text :content
      t.string :image
      t.string :image_content_type
      t.integer :image_size
      t.integer :image_width
      t.integer :image_height
      t.string :attachment
      t.integer :attachment_size
      t.string :attachment_content_type

      t.timestamps
    end
    add_column :proposals, :comment_count, :integer, default: 0
  end
end
