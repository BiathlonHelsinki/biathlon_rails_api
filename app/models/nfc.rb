class Nfc < ApplicationRecord
  belongs_to :user


  def holder_name
    user.display_name
  end

end
