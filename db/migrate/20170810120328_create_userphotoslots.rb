class CreateUserphotoslots < ActiveRecord::Migration[5.0]
  def change
    create_table :userphotoslots do |t|
      t.references :user, foreign_key: true
      t.references :userphoto, foreign_key: true
      t.references :ethtransaction, foreign_key: true
      t.references :activity, foreign_key: true

      t.timestamps
    end
  end
end
