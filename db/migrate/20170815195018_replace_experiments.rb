class ReplaceExperiments < ActiveRecord::Migration[5.0]
  def change
    execute("update comments set item_type='Event' where item_type='Experiment'")
    execute("update pledges set item_type='Event' where item_type='Experiment'")
    execute("update activities set item_type='Event' where item_type='Experiment'")
    execute("update activities set extra_type='Event' where extra_type='Experiment'")
    execute("update notifications set item_type='Event' where item_type='Experiment'")
  end
end
