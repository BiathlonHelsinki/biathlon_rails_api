class Onetimer < ApplicationRecord
  belongs_to :instance, touch: true
  belongs_to :user
  before_validation :generate_code
  validates_presence_of :code, :instance_id
  has_one :activity
  
  scope :today, -> (date) { where(["created_at >= ? and created_at <= ?", date, date])}

  def instance_name
    instance.name
  end
  
  def generate_code
    if code.blank?
      self.code = (0...6).map { (65 + rand(26)).chr }.join + rand(9).to_s 
    end
  end

  
end
