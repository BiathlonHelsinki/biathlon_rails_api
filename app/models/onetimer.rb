class Onetimer < ApplicationRecord
  belongs_to :event
  belongs_to :user
  before_validation :generate_code
  validates_presence_of :code, :event_id
  has_one :activity
  
  def generate_code
    if code.blank?
      self.code = (0...6).map { (65 + rand(26)).chr }.join + rand(9).to_s 
    end
  end

  
end
