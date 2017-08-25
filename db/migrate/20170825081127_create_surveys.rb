class CreateSurveys < ActiveRecord::Migration[5.0]
  def change
    create_table :surveys do |t|
      t.references :user, foreign_key: true
      t.text :never_visited
      t.text :experiment_why
      t.text :platform_benefits
      t.text :different_contribution
      t.text :welcoming_concept
      t.text :physical_environment
      t.text :website_etc
      t.text :different_than_others
      t.text :your_space
      t.boolean :allow_excerpt
      t.boolean :allow_identity
      t.boolean :completed
      t.text :features_benefit
      t.text :improvements
      t.text :clear_structure
      t.text :want_from_culture

      t.timestamps
    end
  end
end
