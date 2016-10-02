class Rate < ApplicationRecord
  belongs_to :instance
  
  validate :only_one_current
  scope :current, -> () { where(current: true) }
  
  before_validation :block_out_others
  protected

  def block_out_others
    if current
      Rate.current.each do |r|
        r.current = false
        r.save
      end
    end
  end
  
  def self.get_current
    self.current.first
  end
  
  def only_one_current
    return unless current?

    matches = Rate.current
    if persisted?
      matches = matches.where('id != ?', id)
    end
    if matches.exists?
      errors.add(:current, 'cannot have another current')
    end
  end
  
  
end
