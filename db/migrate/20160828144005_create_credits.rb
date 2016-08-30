class CreateCredits < ActiveRecord::Migration[5.0]
  def change
    create_table :credits do |t|
      t.references :user, foreign_key: true
      t.integer :awarder_id, foreign_key: true
      t.string :description
      t.references :ethtransaction, foreign_key: true
      t.string :attachment
      t.string :attachment_content_type
      t.integer :attachment_size, length: 8
      t.integer :value
      t.references :rate, foreign_key: true
      t.string :notes
      t.timestamps
    end
    add_column :ethtransactions, :credit_id, :integer
  end
end
