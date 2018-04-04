class FixNilContributors < ActiveRecord::Migration[5.0]
  def change
    Activity.where(contributor:nil).each do |a|
      a.update_column(:contributor_type, 'User')
      a.update_column(:contributor_id, a.user_id)
    end
  end
end
