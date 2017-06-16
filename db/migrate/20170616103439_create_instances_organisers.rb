class CreateInstancesOrganisers < ActiveRecord::Migration[5.0]
  def change
    create_table :instances_organisers do |t|
      t.references :instance, foreign_key: true
      t.integer :organiser_id, foreign_key: true

      t.timestamps
      
    end
    execute "ALTER TABLE instances_organisers ADD UNIQUE (instance_id, organiser_id)"
  end
end
