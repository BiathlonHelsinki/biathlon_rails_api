class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|
      t.string :address, limit: 42, unique: true, null: false
      t.references :user, foreign_key: true
      t.integer :balance

      t.timestamps
    end
  end
end
