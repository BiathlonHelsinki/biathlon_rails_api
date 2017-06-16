class FixActivityFeed < ActiveRecord::Migration[5.0]
  def self.up
    add_column :activities, :numerical_value, :integer
    Activity.all.each do |a|
      if a.description =~ (/\-*\d+/)
        a.update_attribute(:numerical_value, a.description.match(/(\-*\d+)/)[0])
      end
      
      if a.description == 'attended'
        a.update_attribute(:description, 'attended')
      elsif a.description == 'attended anonymously'
        a.update_attribute(:description, 'attended_anonymously')
      elsif a.description == 'booked the back room on '
        a.update_attribute(:description, 'booked_the_back_room_on')
      elsif a.description == 'changed the status of'
        a.update_attribute(:description, 'changed_the_status_of')
      elsif a.description == 'commented on'
        a.update_attribute(:description, 'commented_on')
      elsif a.description == 'edited'
        a.update_attribute(:description, 'edited')
      elsif a.description == 'edited their pledge to'
        a.update_attribute(:description, 'edited_their_pledge_to')  
      elsif a.description =~ /^had their blockchain balance adjusted by/
        a.update_attribute(:description, 'had_blockchain_balance_adjusted_by')
      elsif a.description == 'is no longer planning to attend'
        a.update_attribute(:description, 'is_no_longer_planning_to_attend')
      elsif a.description == 'is no longer registered for '
        a.update_attribute(:description, 'is_no_longer_registered_for')
      elsif a.description == 'joined!'
        a.update_attribute(:description, 'joined')
      elsif a.description == 'linked'
        a.update_attribute(:description, 'linked')
      elsif a.description == 'plans to attend'
        a.update_attribute(:description, 'plans_to_attend')
      elsif a.description == 'pledged to'
        a.update_attribute(:description, 'pledged_to')
      elsif a.description =~ /^pledged \d/
        a.update_attribute(:description, 'pledged')
      elsif a.description == 'proposed'
        a.update_attribute(:description, 'proposed')
      elsif a.description =~ /^received /
        a.update_attribute(:description, 'received_from')
      elsif a.description == 'registered for'
        a.update_attribute(:description, 'registered_for')
      elsif a.description =~ /^spent a pledge of/
        a.update_attribute(:description, 'spent_a_pledge_on')
      elsif a.description == 'was credited for'
        a.update_attribute(:description, 'was_credited_for')
      elsif a.description == 'was mentioned by'
        a.update_attribute(:description, 'was_mentioned_by')
      elsif a.description == 'withdrew a pledge'
        a.update_attribute(:description, 'withdrew_a_pledge')
      # else
      #   a.update_attribute(:description, 'unknown_activity')
      end
      
      if a.extra_info == 'which was scheduled' || a.extra_info == 'which was scheduled as '
        a.update_attribute(:extra_info, 'which_was_scheduled_as')
      end
        
        
    end
  end
  
  def self.down
    remove_column :activities, :numerical_value
  end
  
end
