class CreateRoombookings < ActiveRecord::Migration[5.0]
  def change
    create_table :roombookings do |t|
      t.date :day, null: false
      t.references :user, foreign_key: true, null: false
      t.references :ethtransaction, foreign_key: true
      t.references :rate, foreign_key: true, null: false
      t.string :purpose

      t.timestamps
    end
    add_index :roombookings, :day, unique: true
    add_column :rates, :room_cost, :integer, default: 25, null: false

  end
end
