class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.references :item, polymorphic: true
      t.references :user, foreign_key: true
      t.boolean :pledges
      t.boolean :comments
      t.boolean :scheduling
      t.timestamps
    end
  end
end
