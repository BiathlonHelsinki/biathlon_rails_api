class CreateNfcs < ActiveRecord::Migration[5.0]
  def change
    create_table :nfcs do |t|
      t.references :user, foreign_key: true
      t.string :tag_address, limit: 16
      t.boolean :active

      t.timestamps
    end
    add_index :nfcs, :tag_address, unique: true
    
    
  end
end
