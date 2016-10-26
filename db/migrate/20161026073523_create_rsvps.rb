class CreateRsvps < ActiveRecord::Migration[5.0]
  def change
    create_table :rsvps do |t|
      t.references :instance, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.text :comment

      t.timestamps
    end
    add_index :rsvps, [:instance_id, :user_id], unique: true
  end
end
