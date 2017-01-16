class Proposalstatus < ApplicationRecord
  has_many :proposals
  translates :name, fallbacks_for_empty_translations: true
end
