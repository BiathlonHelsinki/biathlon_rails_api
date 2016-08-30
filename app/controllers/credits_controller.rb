class CreditsController < ApplicationController
  
  
  before_action :authenticate_user!
  
  
  def create
    @credit = Credit.new(credit_params)
    if @credit.save
      logger.warn('yeah')
      render json: {data: @credit.ethtransaction}, status: 200
    else
      render json: @credit.errors, status: :unprocessable_entity
    end
  end
  
  def destroy
    credit = Credit.find(params[:id])
    credit.destroy!
    render json: @credit, status: :deleted
  end
  

  def index
    @credits = Credit.all.order(created_at: :desc)
  end
  

  def update
    @credit = Credit.find(params[:id])
    if @credit.update_attributes(credit_params)
      render json: @credit, status: :updated
    else
      render json: @credit.errors, status: :unprocessable_entity
    end
  end

  
  protected
  
  def credit_params
    params.require(:credit).permit(:attachment, :value, :user_id, :awarder_id, :description, :ethtransaction_id, :rate_id, :notes)    
  end
  
end