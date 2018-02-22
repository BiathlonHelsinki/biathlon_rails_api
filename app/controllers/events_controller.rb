class EventsController < ApplicationController
  include ActiveHashRelation

  load_and_authorize_resource except: [:onetimer,  :user_attend, :today]
  before_action :authenticate_user!, except: [:user_attend, :today, :onetimer]
  before_action :authenticate_hardware!, only: [:user_attend, :onetimer]

  def create
    @event = Event.new(event_params)
    if @event.save
      @event.instances.each do |i|
        i.update_attribute(:published, true)
        i.spend_from_blockchain
      end
      render json: @event, status: :created
    else
      render json: {"error" => @event.errors.inspect}, status: :unprocessable_entity
    end
  end
  

  def today
    # need to fix for multiple day events
    @events = Instance.has_instance_on(Time.now.to_date)

    # render json: {"data" => @events}, status: 200
    render(
      json: InstanceSerializer.new(@events).serialized_json
      # json: @events, each_serializer: InstanceSerializer
      )
  end
    
  def update
    @event = Event.friendly.find(params[:id])
    if @event.update_attributes(event_params)
      render json: @event, status: :updated, location: @event
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end
  

  private
  
  def event_params
    params.require(:event).permit(:place_id, :start_at, :end_at, :sequence, :published, :image, :primary_sponsor_id, :primary_sponsor_type,
            :secondary_sponsor_id, :cost_euros, :cost_bb, :idea_id, :remote_image_url,
            instances_attributes: [:id, :_destroy, :event_id, :cost_bb, :price_public, :start_at, :end_at, :image, 
                                    :custom_bb_fee,
                                    :room_needed, :allow_others, :price_stakeholders, :place_id, 
                                    translations_attributes: [:id, :locale, :_destroy, :name, :description]],
                                  translations_attributes: [:name, :description, :id, :locale])
  end
    
  
end