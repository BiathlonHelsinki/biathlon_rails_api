class FillInVisitDates < ActiveRecord::Migration[5.0]
  def change
    InstancesUser.all.each do |iu|
      if iu.visit_date.nil?
        iu.visit_date = iu.instance.start_at.to_date
      end
      as = Activity.where(addition: 1).where(user: iu.user).where(item: iu.instance)
      unless as.empty?
        iu.activity = as.first
      end
      iu.save
    end
  end
end
