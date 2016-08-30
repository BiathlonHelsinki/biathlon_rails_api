class AddAvatarToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :avatar, :string
    add_column :users, :avatar_content_type, :string
    add_column :users, :avatar_size, :integer, length: 8
    add_column :users, :avatar_width, :integer
    add_column :users, :avatar_height, :integer
  end
end
