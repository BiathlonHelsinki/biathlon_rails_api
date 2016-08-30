class CreateRates < ActiveRecord::Migration[5.0]
  def change
    create_table :rates do |t|
      t.boolean :current
      t.integer :experiment_cost
      t.float :euro_exchange
      t.references :instance, foreign_key: true
      t.text :comments

      t.timestamps
    end
  end
end
