class UsersController < ApplicationController
  include ActiveHashRelation
  
  #skip_before_filter :authenticate_user!, only: [:create]
  before_action :authenticate_hardware!, only: [:link_to_nfc]

  def get_balance
    @user = User.friendly.find(params[:id])
    balance = 0
    api = BidappApi.new
    @user.accounts.each do |account|
      begin
        api_data = api.api_post('/account_balance', {account: account.address})
        balance += api_data.to_i
      rescue
        next
      end
    end
    render json: {data: balance}, status: 200
  end
    
  def link_temporary_tag
    @user = User.friendly.find(params[:user_id])
    @tag = Onetimer.find(params[:tag_id])
    event = @tag.instance
    if event.users.include?(@user)
      render json: {error: 'User already attended this activity'}.to_json, status: :unprocessable_entry
    elsif @tag.claimed == true
      render json: {error: 'This tag was already claimed '}, status: :unprocessable_entry
    else
      if @user.award_points(event, event.cost_bb.nil? ? event.event.cost_bb : event.cost_bb)
        @tag.claimed = true
        @tag.save
        render json: {data: @user}, status: 200, location: @user
      else
        render json: {error: @user.errors.as_json(full_messages: true) }, status: :unprocessable_entity
      end
    end
  end
      
      
  def link_to_nfc
    @user = User.friendly.find(params[:id])
    logger.warn('linking nfc tag with id ' + params[:tag_address] + ' and security code ' + params[:securekey] + ' to user ' + @user.name)
    begin
      @user.nfcs << Nfc.create(tag_address: params[:tag_address], security_code: params[:securekey], active: true)
      render json: {data: @user}, status: 200
    rescue
      render json: {error: 'Error!'}, status: 422
    end
  end
  
  def show
    user = User.find(params[:id])
    render(json: UserSerializer.new(user).to_json)
  end
  
  def index
    if params[:q].blank?
      users = User.all
    else
      users = User.joins(:authentications).fuzzy_search({name: params[:q], email: params[:q], username: params[:q], authentications: { username: params[:q] }}, false)
    end


    render(
      json: users
      )
  end
  
end