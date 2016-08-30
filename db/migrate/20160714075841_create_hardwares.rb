class CreateHardwares < ActiveRecord::Migration[5.0]
  def change
    create_table :hardwares do |t|
      t.string :name
      t.string :slug
      t.macaddr :mac_address
      t.text :description
      t.string :authentication_token, limit: 30
      t.references :hardwaretype, foreign_key: true
      t.timestamps
    end
    add_index :hardwares, :slug, unique: true
    add_index :hardwares, :authentication_token, unique: true
  end
end
