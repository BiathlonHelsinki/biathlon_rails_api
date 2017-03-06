class Proposalstatus < ApplicationRecord
  has_many :proposals
  translates :name, fallbacks_for_empty_translations: true
  
  accepts_nested_attributes_for :translations, :reject_if => proc {|x| x['name'].blank? }
  
  extend FriendlyId
  friendly_id :name_en , :use => [:slugged, :finders]
  
  def name_en
    self.name(:en)
  end
  
end
