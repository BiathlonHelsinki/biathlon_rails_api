class CreateEmails < ActiveRecord::Migration[5.0]
  def change
    create_table :emails do |t|
      t.datetime :sent_at
      t.boolean :sent, default: false, null: false
      t.text :body
      t.string :subject
      t.string :slug

      t.timestamps
    end
  end
end
