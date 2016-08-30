class AddNestedToEvents < ActiveRecord::Migration[5.0]
  def self.up
    add_column :events, :parent_id, :integer, null: true, index: true
    add_column :events, :lft, :integer, index: true
    add_column :events, :rgt, :integer, index: true
    add_column :events, :depth, :integer, null: false, default: 0
    add_column :events, :children_count, :integer, null: false, default: 0
    Event.rebuild!
  end
  

  def self.down
    remove_column :events, :parent_id
    remove_column :events, :lft
    remove_column :events, :rgt
    remove_column :events, :depth
    remove_column :events, :children_count
  end
end
