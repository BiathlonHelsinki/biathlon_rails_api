class Event < ApplicationRecord
  belongs_to :idea, optional: true
  belongs_to :place
  belongs_to :primary_sponsor, polymorphic: true  
  has_many :instances, dependent: :destroy
  translates :name, :description, :fallbacks_for_empty_translations => true
  accepts_nested_attributes_for :translations, :reject_if => proc {|x| x['name'].blank? && x['description'].blank? }
  accepts_nested_attributes_for :instances, :reject_if => proc {|x| x['start_at'].blank? || x['end_at'].blank? }
  acts_as_nested_set
  belongs_to :secondary_sponsor, class_name: 'User'
  has_many :activities, as: :item,  dependent: :destroy
  resourcify
  extend FriendlyId
  friendly_id :name_en , :use => [ :slugged, :finders ]# :history]
  mount_uploader :image, ImageUploader

  validates_presence_of :place_id, :start_at, :primary_sponsor_id,  :primary_sponsor_type
  validate :name_present_in_at_least_one_locale
  before_save :update_image_attributes
  belongs_to :proposal, optional: true
  has_many :pledges, as: :item,  dependent: :destroy
  before_validation :make_first_instance
  validate :at_least_one_instance
 #validates_uniqueness_of :sequence
  after_save :convert_idea
  
  scope :published, -> () { where(published: true) }
  scope :has_events_on, -> (*args) { where(['published is true and cancelled is false and (date(start_at) = ? OR (end_at is not null AND (date(start_at) <= ? AND date(end_at) >= ?)))', args.first, args.first, args.first] )}

  def convert_idea
    if idea
      idea.status = 'converted'
      idea.converted = self
      idea.save
    end
  end
  
  def at_least_one_instance
    if instances.empty?
      errors.add(:base, "At least one instance of this experiment must exist.")
    end
  end
  
  def make_first_instance
    if instances.empty?
      instances << Instance.new(cost_bb: cost_bb, sequence: sequence + ".1", cost_euros: cost_euros, start_at: start_at, end_at: end_at,
                                   place_id: place_id, published: published, translations_attributes: [{locale: 'en', name: name(:en), description: description(:en)}])
    end                          
  end
  
  def future?
    self.start_at >= Date.parse(Time.now.strftime('%Y/%m/%d'))
  end
  
  def make_first_instance

    if instances.empty?
      
      instances << Instance.new(cost_bb: cost_bb, sequence: sequence, cost_euros: cost_euros, start_at: start_at, end_at: end_at,
                                   place_id: place_id, published: published, translations_attributes: [{locale: 'en', name: name(:en), description: description(:en)}])

    end                          
  end
  
  def name_en
    self.name
  end
  
  def name_present_in_at_least_one_locale
    logger.warn 'name is ' + self.translations.inspect
    if I18n.available_locales.map { |locale| translation_for(locale).name }.compact.empty?
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
