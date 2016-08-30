class CreateAuthentications < ActiveRecord::Migration[5.0]
  def change
    create_table :authentications do |t|
      t.string :provider
      t.string :username
      t.string :uid
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :authentications, [:user_id, :provider, :uid], unique: true
  end
end
