class CreatePostcategories < ActiveRecord::Migration[5.0]
  def self.up
    create_table :postcategories do |t|
      t.string :slug
      t.timestamps
    end
    add_column :posts, :postcategory_id, :integer, index: true
    Postcategory.create_translation_table! name: :string
  end
  
  def self.down
    drop_table :postcategories
    drop_column :posts, :postcategory_id
    Postcategory.drop_translation_table!
  end
end
