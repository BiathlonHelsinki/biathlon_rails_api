class Post < ApplicationRecord
  belongs_to :user
  translates :title, :body, :fallbacks_for_empty_translations => true
  extend FriendlyId
  friendly_id :title_en , :use => [:slugged, :finders]
  accepts_nested_attributes_for :translations, :reject_if => proc {|x| x['title'].blank? || x['body'].blank? }
  before_save :update_image_attributes
  before_save :check_published
  mount_uploader :image, ImageUploader
  
  scope :published, -> () { where(published: true) }
  def title_en
    self.title(:en)
  end
  
  def check_published
    if self.published == true
      self.published_at ||= Time.now
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
  
  private
  
  def should_generate_new_friendly_id?
    changed?
  end
  
end
