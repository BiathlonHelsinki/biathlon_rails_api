class Userphoto < ApplicationRecord
  belongs_to :instance
  belongs_to :user
end
