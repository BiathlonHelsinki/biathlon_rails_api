class CreateEvents < ActiveRecord::Migration[5.0]
  def self.up
    create_table :events do |t|
      t.references :place, foreign_key: true
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :published
      t.integer :primary_sponsor_id, foreign_key: true
      t.integer :secondary_sponsor_id, foreign_key: true
      t.string :slug, unique: true
      t.float :cost_euros
      t.integer :cost_bb

      t.timestamps
    end
    Event.create_translation_table! name: :string, description: :text
  end
  
  def self.down
    drop_table :events
    Event.drop_translation_table!  
  end
  
end
