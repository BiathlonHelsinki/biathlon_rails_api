class CreateUserlinks < ActiveRecord::Migration[5.0]
  def change
    create_table :userlinks do |t|
      t.string :url
      t.references :user, foreign_key: true
      t.references :instance, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
