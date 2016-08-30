
class CreateOnetimers < ActiveRecord::Migration[5.0]
  def change
    create_table :onetimers do |t|
      t.references :event, foreign_key: true
      t.string :code, limit: 7
      t.boolean :claimed, default: false, null: false
      t.references :user, foreign_key: true
      t.timestamps
    end
    add_index :onetimers, :code, unique: true
  end
end
