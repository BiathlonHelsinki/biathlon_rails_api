class Instance < ApplicationRecord
  belongs_to :experiment, foreign_key: 'event_id'
  belongs_to :place
  translates :name, :description, :fallbacks_for_empty_translations => true
  accepts_nested_attributes_for :translations, :reject_if => proc {|x| x['name'].blank? && x['description'].blank? }
  extend FriendlyId
  friendly_id :name_en , :use => [ :slugged, :finders ] # :history]
  mount_uploader :image, ImageUploader
  validates_presence_of :place_id, :start_at
  validates_uniqueness_of :sequence
  belongs_to :proposal
  has_many :instances_users
  has_many :users, through: :instances_users
  has_many :onetimers, dependent: :destroy
  before_save :spend_from_blockchain
  
  #validate :name_present_in_at_least_one_locale
  scope :between, -> (start_time, end_time) { 
    where( [ "(start_at >= ?  AND  end_at <= ?) OR ( start_at >= ? AND end_at <= ? ) OR (start_at >= ? AND start_at <= ?)  OR (start_at < ? AND end_at > ? )",
    start_time, end_time, start_time, end_time, start_time, end_time, start_time, end_time])
  }
  scope :published, -> () { where(published: true) }
  scope :meetings, -> () {where(is_meeting: true)}
  scope :future, -> () {where(["start_at >=  ?", Time.now.strftime('%Y/%m/%d %H:%M')]) }
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
      :url => Rails.application.routes.url_helpers.instance_path(slug),
      #:color => "red"
    }

  end
  
  def children
    []
  end
  
  def self.next_meeting
    self.future.meetings.first
  end
  
  def spend_from_blockchain
    if proposal
      if proposal.scheduled != true
        api = BidappApi.new
        proposal.pledges.each do |pledge|
          next if pledge.converted == 1      # shouldn't happen here but just to be paranoid
          transaction = api.spend(pledge.user.accounts.primary.first.address, pledge.pledge)
          pledge.user.accounts.primary.first.balance = pledge.user.accounts.primary.first.balance.to_i - pledge.pledge
          pledge.user.update_balance_from_blockchain
          pledge.converted = 1
          pledge.user.save(validate: false)
          et = nil
          while et.nil? do
            et = Ethtransaction.find_by(txaddress: transaction)
          end

          proposal.activities <<  Activity.create(user: pledge.user, item: proposal, ethtransaction_id: et.id, description: "spent a pledge of #{pledge.pledge}#{ENV['currency_symbol']} on", extra_info: 'which was scheduled', addition: -1)    
        end
        proposal.scheduled = true
        proposal.save!
      end
    end
  end
  
  private
  
  
  def should_generate_new_friendly_id?
    changed?
  end
  
  def name_en
    self.name(:en).blank? ? experiment.name(:en) : self.name(:en)
  end
  
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
