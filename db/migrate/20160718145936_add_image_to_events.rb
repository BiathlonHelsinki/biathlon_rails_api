class AddImageToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :image, :string
    add_column :events, :image_content_type, :string
    add_column :events, :image_size, :integer, length: 8
    add_column :events, :image_width, :integer
    add_column :events, :image_height, :integer
  end
end
