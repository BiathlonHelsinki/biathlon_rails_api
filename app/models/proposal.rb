class Proposal < ApplicationRecord

  belongs_to :user
  has_many :images, as: :item, :dependent => :destroy
  has_many :pledges, as: :item, :dependent => :destroy
  accepts_nested_attributes_for :images, :reject_if => proc {|attributes| attributes['image'].blank? && attributes['image_cache'].blank?}, :allow_destroy => true
  accepts_nested_attributes_for :pledges
  validates_presence_of :user_id, :name, :short_description, :timeframe, :goals, :intended_participants
  has_many :comments, as: :item, :dependent => :destroy
  accepts_nested_attributes_for :comments, reject_if: proc{|attr| attr['content'].blank? }
  has_many :instances
  has_many :activities, dependent: :destroy, as: :item
  after_create :add_to_activity_feed
  after_update :add_to_activity_feed_edited
  belongs_to :proposalstatus
  
  scope :archived, -> () { where(stopped: true) }
  scope :active, -> () { where(stopped: false) }
  before_save :update_column_caches

  def update_column_caches
    self.total_needed_with_recurrence_cached = total_needed_with_recurrence
    self.needed_array_cached = needed_array
    self.has_enough_cached = has_enough?
    self.number_that_can_be_scheduled_cached = number_that_can_be_scheduled
    self.pledgeable_cached  = pledgeable?
    self.pledged_cached = pledged
    self.remaining_pledges_cached = remaining_pledges
    self.spent_cached = spent
    self.published_instances = instances.published.size

  end
  
  def is_valid?
    proposalstatus.nil? || proposalstatus.slug != 'invalid'
  end

  def comments_and_pledges
    [comments, pledges].flatten.sort_by(&:updated_at)
  end
  
  def add_to_activity_feed
    Activity.create(user: user, item: self, description: 'proposed')
  end
  
  def add_to_activity_feed_edited
    Activity.create(user: user, item: self, description: 'edited') if self.short_description_changed? || self.goals_changed? || self.name_changed? || self.intended_participants_changed?
  end
  
  def self.schedulable
    active.includes(:pledges).to_a.delete_if{|x| x.remaining_pledges == 0}.delete_if{ |x| x.remaining_pledges < x.needed_for_next  }.sort_by(&:name)
  end
  
  def feed_date
    comments_and_pledges.empty? ? updated_at : comments_and_pledges.last.updated_at
  end
  
  def recurs?
    recurrence == 2 || recurrence == 3
  end
  
  def needed_array
    rate = Rate.get_current.experiment_cost
    if published_instances == 0
      array = [rate]
      if intended_sessions.blank? || intended_sessions =~ /\D/
        sesh = 35
      else
        sesh = intended_sessions - 1
      end
      if recurs?
        for f in 1..sesh  do 
          inrate = rate
          f.times do
            inrate *= 0.9;
          end
          if inrate < 20
            start = 20
          else
            start = inrate.round
          end
          array.push(start)
        end
      end
      return array
    else
      out = instances.published.order(:start_at).map(&:cost_in_temps)
      if intended_sessions.blank? || intended_sessions =~ /\D/
        sesh = 35
      else
        sesh = intended_sessions - 1
      end
      if recurs?
        for f in published_instances..sesh  do 
          out.push(needed_for(f))
        end
        return out
      end
    end
  end
  
  def cumulative_needed_for(val)

    rate = Rate.get_current.experiment_cost
    if instances.published.empty?
      array = [rate]
      cum = rate
      if recurs?
        for f in 1..val  do 
          inrate = rate
          f.times do
            inrate *= 0.9;
          end
          if inrate < 20
            start = 20
          else
            start = inrate.round
          end
          array.push(start)
          cum += start
        end
        return cum
      else
        return rate
      end
    else
      already = published_instances
      out = instances.published.sum(&:cost_in_temps)
      if recurs?
        for f in already..val do
          out += needed_for(f)
        end
        return out
      end
    end
  end
  
  def needed_for(val)
    # YAML.load(needed_array_cached)[val]
    if published_instances == 0
      rate = Rate.get_current.experiment_cost
    elsif published_instances <= val # instances.published.order(:sequence)[val].nil?
      rate = Rate.get_current.experiment_cost
    else
      return instances.published.order(:sequence)[val].cost_in_temps
    end
    if rate
      array = [rate]
      if recurs?
        for f in 1..val  do
          inrate = rate
          f.times do
            inrate *= 0.9;
          end
          if inrate < 20
            start = 20
          else
            start = inrate.round
          end
          array.push(start)
        end
        return array[val]
      else
        return rate
      end
    end
  end
  
  def has_for(val)
    max = cumulative_needed_for(val)
    if pledged >= max
      needed_for(val)
    else
      if  needed_for(val) - (max - pledged) <= 0
        0
      else
         needed_for(val) - (max - pledged)
      end
    end
  end
    
  
  def needed_for_next
    rate = Rate.get_current.experiment_cost
    if recurs?
      if instances.published.empty?
        Rate.get_current.experiment_cost
      else
        # check if rate changed
        if rate == instances.published.order(:start_at).first.cost_in_temps        
          r = instances.published.order(:start_at).last.cost_in_temps * 0.9
          if r.round < 20
            20
          else
            r.round
          end
        else
          needed_for(published_instances)
        end
      end
    else
      if instances.published.empty?
        Rate.get_current.experiment_cost
      else
        0
      end
    end
  end
  
  def has_enough?
    remaining_pledges >= needed_for_next && (pledges.map(&:user).uniq.size > 1)
  end
  
  def number_that_can_be_scheduled
    rate = Rate.get_current.experiment_cost
    tally = 0
    if recurs?
      if published_instances > YAML.load(needed_array_cached).size
        return (remaining_pledges / YAML.load(needed_array_cached).last).to_i
      elsif remaining_pledges > YAML.load(needed_array_cached)[(published_instances)..-1].sum
        return YAML.load(needed_array_cached)[(published_instances).-1].size
      else
        YAML.load(needed_array_cached)[(published_instances)..-1].each_with_index do |val, index|
          tally += val
          if remaining_pledges >= tally
            next
          else
            return index # - published_instances
          end
        end
      end
    else
      return (remaining_pledges >= rate) ? 1 : 0
    end
  end
  

  def total_needed_with_recurrence
  #   return 0
  # end
  #
  # deftotal_backup
    rate = Rate.get_current.experiment_cost
    if recurs?
      start = rate
      if intended_sessions == 0
        cumulative_needed_for(published_instances)
      else
        if instances.published.empty?
          for f in 1..(intended_sessions-1)  do 
            inrate = rate
            f.times do
              inrate *= 0.9;
            end
            if inrate < 20
              start += 20
            else
              start += inrate.round
            end
          end
          return start
        else
          if rate == instances.published.order(:start_at).first.cost_in_temps
          
            for f in 1..(intended_sessions-1)  do 
              inrate = rate
              f.times do
                inrate *= 0.9;
              end
              if inrate < 20
                start += 20
              else
                start += inrate.round
              end
            end
            return start
        
          else
            addto = instances.published.map{|x| x.cost_in_temps}.sum
            if published_instances == intended_sessions
              start = 0
            else
              start = 0
              for f in (published_instances)..(intended_sessions - 1)  do 
                
                inrate = rate
                f.times do
                  inrate *= 0.9;
                end
                if inrate < 20
                  start += 20
                else
                  start += inrate.round
                end
              end
            end

            return start + addto
          end
        end
      end
    else
      return rate
    end
  end
  
  def pledgeable?
    if recurs?
      if intended_sessions == 0
        true
      else
        total_needed_with_recurrence - spent - remaining_pledges > 0
      end
    else
      total_needed_with_recurrence - spent - remaining_pledges > 0
    end
  end
  
  def maximum_pledgeable(user)
    if pledges.map(&:user).include?(user)  # user has already pledged
      if has_enough?
        if recurs?
          if intended_sessions == 0
            user.available_balance + (pledges.unconverted.find_by(user: user).nil? ? 0 :  pledges.unconverted.find_by(user: user).pledge)
          else
            (user.available_balance + pledges.unconverted.find_by(user: user).pledge) > cumulative_needed_for(intended_sessions) ? cumulative_needed_for(intended_sessions) : (user.available_balance + pledges.unconverted.find_by(user: user).pledge) 
          end
        else
          pledges.unconverted.find_by(user: user).pledge
        end
      
      elsif pledges.map(&:user).size == 1
        Rate.get_current.experiment_cost - 1
      else
        cumulative_needed_for(intended_sessions) 
      end
    else    # user has not yet pledged
      if has_enough?
        if recurs?
          if intended_sessions == 0
            user.available_balance
          else
             (user.available_balance  > cumulative_needed_for(intended_sessions)) ? cumulative_needed_for(intended_sessions) : user.available_balance
           end
        else
          0
        end

      elsif pledges.to_a.delete_if(&:new_record?).empty?
        if instances.published.empty?
          total_needed_with_recurrence - 1
        else
          total_needed_with_recurrence
        end
      else
        total_needed_with_recurrence
      end
    end
  end
  
  def pledged
    pledges.sum{|x| x.pledge.to_i}
  end
  
  def remaining_pledges
    pledged - spent
    #instances.published.sum(&:cost_in_temps)
  end
  
  def discussion
    [pledges, comments].flatten.compact
  end
  
  def scheduled?
    !instances.published.empty?
  end
  
  def spent
    # activities.where(addition: -1).map(&:ethtransaction).sum(&:value) rescue 0
    pledges.converted.sum(&:pledge)
  end
  
  def next_instance
    if scheduled?
      if instances.first.experiment.instances.current.or(instances.first.experiment.instances.future).order(:start_at).empty?
        nil
      else
       instances.first.experiment.instances.current.or(instances.first.experiment.instances.future).order(:start_at).first
        
      end
    else
      nil
    end
  end
end
