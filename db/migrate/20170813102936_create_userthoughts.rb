class CreateUserthoughts < ActiveRecord::Migration[5.0]
  def change
    create_table :userthoughts do |t|
      t.references :instance, foreign_key: true
      t.references :user, foreign_key: true
      t.text :thoughts
      t.integer :karma

      t.timestamps
    end
  end
end
