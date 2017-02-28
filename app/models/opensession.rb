class Opensession < ApplicationRecord
  belongs_to :node
  
  scope :by_node, ->(x) { where(node_id: x)}
  
  
  def seconds_open
    end_time =  closed_at.nil? ? Time.current : closed_at
    # elapsed_seconds = ((end_time - opened_at) * 24 * 60 * 60).to_i
    end_time - opened_at
  end
  
  def minutes_open
    (seconds_open / 60).to_i
  end
  
end
