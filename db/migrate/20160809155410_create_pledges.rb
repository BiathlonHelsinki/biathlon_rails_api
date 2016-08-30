class CreatePledges < ActiveRecord::Migration[5.0]
  def change
    create_table :pledges do |t|
      t.references :item, polymorphic: true
      t.references :user, foreign_key: true
      t.integer :pledge
      t.string :comment
      t.integer :converted

      t.timestamps
    end
  end
end
