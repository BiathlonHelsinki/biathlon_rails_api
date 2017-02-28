class OpensessionsController < ApplicationController

  before_action :authenticate_hardware!
  
  def open
    @node = Node.friendly.find(params[:node_id])
    # are we already open? 
    sesh = Opensession.by_node(@node.id).find_by(closed_at: nil)
    if sesh.nil?
      sesh = Opensession.new(node: @node, opened_at: Time.current, closed_at: nil)
      if sesh.save
        render json: {data: sesh}, status: 200
      else
        render json: {error: 'cannot open ' + @node.name }, status: 401
      end 
    else  # already open, so fuck it

      render json: {data: sesh}, status: 200
    end
  end
  
  
  
  def close
    @node = Node.friendly.find(params[:node_id])
    # are we already closed?
    sesh = Opensession.by_node(@node.id).find_by(closed_at: nil)   # should be empty
    if sesh.nil?

      render json: {data: sesh}, status: 200
    else
      sesh.closed_at = Time.current
      if sesh.save
        render json: {data: sesh}, status: 200
      else
        render json: {error: 'cannot open ' + @node.name }, status: 401
      end 
   end
 end
 
end
