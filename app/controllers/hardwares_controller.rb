class HardwaresController < ApplicationController

  before_action :authenticate_hardware!
  
  def i_am_alive
    if current_hardware.checkable?
      current_hardware.update_attribute(:last_checked_at, Time.current)
      current_hardware.update_attribute(:notified_of_error, false)
    end
  end
end
