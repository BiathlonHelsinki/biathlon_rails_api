class CreateNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :notifications do |t|
      t.references :item, polymorphic: true
      t.references :user, foreign_key: true
      t.boolean :pledges, default: false, null: false
      t.boolean :comments, default: true, null: false
      t.boolean :scheduling, default: true, null: false
      t.timestamps
    end
  end
end
