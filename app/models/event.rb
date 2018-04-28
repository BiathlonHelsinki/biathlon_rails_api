class Event < ApplicationRecord
  resourcify
  belongs_to :idea, optional: true
  belongs_to :place
  belongs_to :proposal, optional: true
  belongs_to :primary_sponsor, polymorphic: true  
  has_many :instances, foreign_key: 'event_id', dependent: :destroy
  translates :name, :description, :fallbacks_for_empty_translations => true
  accepts_nested_attributes_for :translations, :reject_if => proc {|x| x['name'].blank? && x['description'].blank? }
  accepts_nested_attributes_for :instances, :reject_if => proc {|x| x['start_at'].blank? || x['end_at'].blank? }
  has_many :notifications, as: :items
  has_many :ideas, as: :parent
  belongs_to :parent, class_name: 'Event', optional: true
  has_one :child, class_name: 'Event', foreign_key: :parent_id
  extend FriendlyId
  friendly_id :name_en , :use => [ :slugged, :finders ] # :history]
  mount_uploader :image, ImageUploader
  process_in_background :image

  validates_presence_of :place_id, :start_at, :primary_sponsor_id
  validate :name_present_in_at_least_one_locale
  before_save :update_image_attributes
  has_many :comments, as: :item, :dependent => :destroy
  has_many :pledges, -> { where item_type: "Event"}, foreign_key: :item_id, foreign_type: :item_type,   dependent: :destroy
  acts_as_nested_set
  belongs_to :secondary_sponsor, class_name: 'User'
  #####
  before_validation :make_first_instance
  validate :at_least_one_instance
  #######

  after_save :convert_idea
  

  scope :published, -> () { where(published: true) }
  scope :has_events_on, -> (*args) { where(['published is true and (date(start_at) = ? OR (end_at is not null AND (date(start_at) <= ? AND date(end_at) >= ?)))', args.first, args.first, args.first] )}
  scope :between, -> (start_time, end_time) { 
    where( [ "(start_at >= ?  AND  end_at <= ?) OR ( start_at >= ? AND end_at <= ? ) OR (start_at >= ? AND start_at <= ?)  OR (start_at < ? AND end_at > ? )",
    start_time, end_time, start_time, end_time, start_time, end_time, start_time, end_time])
  }

  def at_least_one_instance
    if instances.empty?
      errors.add(:base, "At least one instance of this experiment must exist.")
    end
  end

  def convert_idea
    if idea
      idea.status = 'converted'
      idea.converted = self
      idea.save
    end
  end

  def future?
    self.start_at >= Date.parse(Time.now.strftime('%Y/%m/%d'))
  end

  
  def make_first_instance
    if instances.empty?
      instances << Instance.new(cost_bb: cost_bb, sequence: sequence + ".1", price_public: cost_euros, start_at: start_at, end_at: end_at,
                                   place_id: place_id, published: published, translations_attributes: [{locale: 'en', name: name(:en), description: description(:en)}])
    end                          
  end

  def next_sequence
    instances.map(&:sequence).map(&:to_i).sort.last + 1
  end
  
  def name_en
    self.name
  end
  
  def name_present_in_at_least_one_locale

    if I18n.available_locales.map { |locale| translation_for(locale).name }.compact.empty?
      # logger.warn('map is ' + I18n.available_locales.map { |locale| translation_for(locale).name }.inspect)
      errors.add(:base, "You must specify an event name in at least one available language.")
    end
  end
  
  def place_name
    place.blank? ? nil : place.name
  end
  
  def title
    name    
  end
  
  private
  
  def should_generate_new_friendly_id?
    changed?
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
