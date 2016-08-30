class Pledge < ApplicationRecord
  belongs_to :item, polymorphic: true
  belongs_to :user
end
