class AddDeletedAtToCredits < ActiveRecord::Migration[5.0]
  def change
    add_column :credits, :deleted_at, :datetime
    add_index :credits, :deleted_at
  end
end
