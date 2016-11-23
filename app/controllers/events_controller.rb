class EventsController < ApplicationController
  include ActiveHashRelation

  load_and_authorize_resource except: [:onetimer,  :user_attend, :today]
  before_action :authenticate_user!, except: [:user_attend, :today, :onetimer]
  before_action :authenticate_hardware!, only: [:user_attend, :onetimer]

  def create
    @event = Event.new(event_params)
    if @event.save
      render json: @event, status: :created
    else
      render json: @event.errors, status: :unprocessable_entity
    end
  end
  

  def today
    # need to fix for multiple day events
    @events = Instance.has_instance_on(Time.now.to_date)

    # render json: {"data" => @events}, status: 200
    render(
      json: @events, each_serializer: InstanceSerializer
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
    params.require(:event).permit(:place_id, :start_at, :end_at, :sequence, :published, :image, :primary_sponsor_id, :secondary_sponsor_id, :cost_euros, :cost_bb, 
                                  translations_attributes: [:name, :description, :id, :locale])
  end
    
  
end