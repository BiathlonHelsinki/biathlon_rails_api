class CreateActivities < ActiveRecord::Migration[5.0]
  def change
    create_table :activities do |t|
      t.references :user #, foreign_key: true
      t.references :transaction, foreign_key: true
      t.references :item, polymorphic: true
      t.string :description

      t.timestamps
    end
  end
end
