class Instance < ApplicationRecord
  belongs_to :event
  belongs_to :place
  translates :name, :description, :fallbacks_for_empty_translations => true
  accepts_nested_attributes_for :translations, :reject_if => proc {|x| x['name'].blank? && x['description'].blank? }
  accepts_nested_attributes_for :event
  extend FriendlyId
  friendly_id :name , :use => [ :slugged, :finders , :history]
  mount_uploader :image, ImageUploader
  validates_presence_of :place_id, :start_at, :end_at, :custom_bb_fee,  :cost_bb, :room_needed, :price_public, :price_stakeholders
  # validates_uniqueness_of :sequence
  belongs_to :proposal, optional: true
  belongs_to :idea
  has_many :pledges
  has_many :instances_users
  has_many :instances_organisers
  has_many :users, through: :instances_users
  has_many :organisers, through: :instances_organisers
  has_many :onetimers, dependent: :destroy
  before_save :spend_from_blockchain
  has_many :registrations, dependent: :destroy
  
  attr_accessor :send_to_pledgers
    
  after_save -> {
    unless proposal.blank?
      proposal.update_column_caches
      
      proposal.save! 
    end

  } 
  
  #validate :name_present_in_at_least_one_locale
  scope :between, -> (start_time, end_time) { 
    where( [ "(start_at >= ?  AND  end_at <= ?) OR ( start_at >= ? AND end_at <= ? ) OR (start_at >= ? AND start_at <= ?)  OR (start_at < ? AND end_at > ? )",
    start_time, end_time, start_time, end_time, start_time, end_time, start_time, end_time])
  }
  scope :published, -> () { where(published: true) }
  scope :meetings, -> () {where(is_meeting: true)}
  scope :future, -> () {where(["start_at >=  ?", Time.now.utc.strftime('%Y/%m/%d %H:%M')]) }
  scope :past, -> () {where(["end_at <  ?", Time.now.utc.strftime('%Y/%m/%d %H:%M')]) }
  scope :current, -> () { where(["start_at <=  ? and end_at >= ?", Time.now.utc.strftime('%Y/%m/%d %H:%M'), Time.now.utc.strftime('%Y/%m/%d %H:%M') ]) }
  scope :not_open_day,  -> ()  { where("event_id != 1")}
  scope :has_instance_on, -> (*args) { where(['published is true and (date(start_at) = ? OR (end_at is not null AND (date(start_at) <= ? AND date(end_at) >= ?)))', args.first, args.first, args.first] )}
    
  def as_json(options = {})
    {
      :id => self.id,
      :title => self.name,
      :description => self.description || "",
      :start => start_at.strftime('%Y-%m-%d %H:%M:00'),
      :end => end_at.nil? ? start_at.strftime('%Y-%m-%d %H:%M:00') : end_at.strftime('%Y-%m-%d %H:%M:00'),
      :allDay => false, 
      :recurring => false,
      :temps => self.cost_bb,
      :url => Rails.application.routes.url_helpers.instance_path(slug)

    }

  end
  
  def event_image
    !image? ? event.image : image
  end

  def children
    []
  end
  
  def self.next_meeting
    self.future.meetings.first
  end
  
  def responsible_people
    [event.primary_sponsor, event.secondary_sponsor, organisers].compact.uniq
  end
  
  def checked_in_so_far
    instances_users.where(visit_date: Time.current.localtime.to_date).size + onetimers.today(Time.current.localtime.to_date).size
  end


  def spend_from_blockchain
    activity_cache = Array.new
    pledge_cache = Array.new
    if published == true && spent_biathlon == false
      counter = cost_in_temps
      
            
      if proposal
        if proposal.still_proposal?
          pledge_object = proposal
        else
          pledge_object = event
        end
      else
        pledge_object = event.idea
      end
      if pledge_object.pledges.unconverted.sum(&:pledge) >= counter

        pledge_object.pledges.unconverted.order(:created_at).each do |pledge| 
          next if counter < 1
          if pledge.pledge <= counter
            next if pledge.converted == 1      # shouldn't happen here but just to be paranoid
            # p 'converting pledge from ' + pledge.user.username + ' of ' + pledge.pledge.to_s
            spent = pledge.pledge
          elsif pledge.pledge >= counter        # pledge overlaps what's needed so take just what's needed 
            # p 'reducing pledge of ' + pledge.user.username + ' of ' + pledge.pledge.to_s
            spent = counter
            if pledge_object.class == Proposal
              newitemrecipient = event
            else
              newitemrecipient = proposal
            end
            #  instead of creating new pledge, restore points to user
            pledge.pledger.update_column(:latest_balance, pledge.pledger.latest_balance + (pledge.pledge - counter))
            # newpledge = Pledge.create(item: newitemrecipient, user: pledge.user, pledge: pledge.pledge - counter, converted: 0, comment: pledge.comment, extra_info: 'remaining from previous pledge after ' + counter.to_s + ENV['currency_symbol'] + ' was spent on scheduling' )
            pledge.update_column(:pledge, counter)
          end
          pledge.update_attribute(:spent_at, Time.current.utc)
          pledge.update_column(:extra_info, 'pledge_spent_at')
          pledge.update_column(:converted, 1)
          pledge_cache.push(pledge)
          counter -= spent
          begin
              # make the activity first
            b = BlockchainTransaction.new(value: spent, account: pledge.pledger.accounts.primary.first, transaction_type: TransactionType.find_by(name: 'Spend'))
            a = Activity.create(user: pledge.user, contributor: pledge.pledger, item: pledge_object, ethtransaction_id: nil, 
              description: "spent_a_pledge_on",  numerical_value: spent, 
              extra_info: 'which_was_scheduled_as',  addition: -1, txaddress: nil, blockchain_transaction: b)
              

            if b.save
              BlockchainHandlerJob.perform_later b
              # a.save
              activity_cache.push(a)

            end
          rescue Exception => e
            # don't write anything unless it goes to blockchain
            logger.warn('spending error: ' + e.inspect)  
            pledge.update_attribute(:converted, false)
            pledge.update_attribute(:extra_info, nil)
            return transaction
          end
        end
        
        if pledge_object.class == Proposal
          proposal.scheduled = true
          proposal.save!
        end
        self.spent_biathlon = true
      end
      activity_cache.each do |ac|
        ac.extra = self        
        ac.save
      end
      pledge_cache.each do |pc|
        pc.instance = self
        pc.save
      end
    end
  end
 
  
  
  def in_future?
    start_at >= Time.now
  end
  
  def session_number
    if new_record?
      event.instances.order(:start_at).size + 1
    else 
      event.instances.order(:start_at).find_index(self) + 1
    end
  end
  
  def cost_in_temps
    if custom_bb_fee
      return custom_bb_fee
    else
      rate = Rate.get_current.experiment_cost
      start = rate
  
      for f in 1..(session_number-1)  do 
        inrate = rate
        f.times do
          inrate *= 0.9;
        end
        if inrate < 20
          start = 20
        else
          start = inrate.round
        end
      end
      return start
    end
  end
  
  
  private
  
  
  def should_generate_new_friendly_id?
    changed?
  end
  
  # def name_en
  #   self.nil? ? event.name(:en) :
  #    (self.name.blank? ?
  #     (self.event.nil? ? self.name(:fi) : 
  #     self.name ) : 'Needs English name' )
  # end
  
  def name_present_in_at_least_one_locale
    
    if I18n.available_locales.map { |locale| translation_for(locale).name }.compact.empty?
      errors.add(:base, "You must specify an event name in at least one available language.")
    end
  end
  
  def update_image_attributes
    if image.present? && image_changed?
      if image.file.exists?
        self.image_content_type = image.file.content_type
        self.image_size = image.file.size
        self.image_width, self.image_height = `identify -format "%wx%h" #{image.file.path}`.split(/x/)
      end
    end
  end
  
end
