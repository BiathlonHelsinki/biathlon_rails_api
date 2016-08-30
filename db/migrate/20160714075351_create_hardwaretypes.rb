class CreateHardwaretypes < ActiveRecord::Migration[5.0]
  def change
    create_table :hardwaretypes do |t|
      t.string :name
      t.string :slug
      t.text :description

      t.timestamps
    end
    add_index :hardwaretypes, :slug, unique: true
  end
  
  def data
    Hardwaretype.create(name: 'Terminal', description: 'Check-in terminal to read id cards')
  end
end
