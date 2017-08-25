class AddSurveylockedToInstances < ActiveRecord::Migration[5.0]
  def change
    add_column :instances, :survey_locked, :boolean
  end
end
