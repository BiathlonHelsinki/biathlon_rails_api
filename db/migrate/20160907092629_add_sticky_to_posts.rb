class AddStickyToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :sticky, :boolean
    add_column :posts, :instance_id, :integer, index: true
  end
end
