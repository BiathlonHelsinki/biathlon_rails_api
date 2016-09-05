class InstancesController < ApplicationController
  include ActiveHashRelation
  load_and_authorize_resource except: [:onetimer,  :user_attend, :today], find_by: :slug
  before_action :authenticate_user!, except: [:user_attend, :today, :onetimer]
  before_action :authenticate_hardware!, only: [:user_attend, :onetimer]

  
  def create
    @instance = Instance.new(instance_params)
    if @instance.save
      render json: {data: @instance}, status: 200
    else
      render json: {error: @instance.errors.full_messages.join(';')}, status: :unprocessable_entity
    end
  end
  
  def destroy
    @instance = Instance.friendly.find(params[:id])
    @instance.destroy!
    render json: @instance, status: :deleted
  end
  
  
  def onetimer
    event = Instance.friendly.find(params[:id])
    @onetimer = Onetimer.create(instance: event)
    if @onetimer.save
      Activity.create(user_id: 0, item: event,                   
                  description: 'attended anonymously', onetimer: @onetimer, addition: 0 )
      render json: @onetimer, status: 200
    else
      render json: @onetimer.errors, status: :unprocessable_entity
    end
  end
  
  def update

    @instance = Instance.friendly.find(params[:id])
    
    if @instance.update_attributes(instance_params)
      render json: {data: @instance}, status: :updated
    else
      render json: {error: @instance.errors.full_messages.join('; ')}, status: :unprocessable_entity
    end
  end
  
  def user_attend
    @user = User.friendly.find(params[:user_id])
    event = Instance.friendly.find(params[:id])
    if @user.award_points(event, event.cost_bb)
      render json: @user, status: 200, location: @user
    else
      render json: {error: @user.errors.as_json(full_messages: true) }, status: :unprocessable_entity
    end
  end
  
  private
  
  def instance_params
    params.require(:instance).permit(:published, :event_id, :place_id, :primary_sponsor_id, :is_meeting, :proposal_id,
    :secondary_sponsor_id, :cost_euros, :cost_bb, :sequence, :start_at, :end_at, :sequence, 
    :parent_id, :image, translations_attributes: [:name, :description, :locale, :id]
    )
  end  
end