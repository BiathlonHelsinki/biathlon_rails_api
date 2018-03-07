class UsersController < ApplicationController
  include ActiveHashRelation

  #skip_before_filter :authenticate_user!, only: [:create]
  before_action :authenticate_hardware!, only: [:link_to_nfc, :get_eth_address]
  before_action :authenticate_user!, only: [:resubmit, :respend]
  before_action :authenticate_admin,  only: [:resubmit, :respend]

  def get_eth_address
    @user = User.friendly.find(params[:id])
    render json: {"address" => @user.get_eth_address}, status: 200
  end

  def get_balance
    @user = User.friendly.find(params[:id])
    GetbalanceJob.perform_later @user
    render json: {data: @user.latest_balance}, status: 200
  end

  def link_temporary_tag
    @user = User.friendly.find(params[:user_id])
    @tag = Onetimer.find(params[:tag_id])
    event = @tag.instance
    if event.users.include?(@user)
      if event.allow_multiple_entry == true
        today = @tag.created_at.to_date
        if @user.instances_users.where(instance: event, visit_date: today).empty?
          if @user.award_points(event, event.cost_bb.nil? ? event.event.cost_bb : event.cost_bb, today.to_s)
            @tag.claimed = true
            @tag.user = @user
            @tag.save
            render json: {data: @user}, status: 200, location: @user
          else

            render json: {error: @user.errors.as_json(full_messages: true) }, status: :unprocessable_entity
          end
        else
          render json: {error: 'User already attended this activity'}.to_json, status: :unprocessable_entry
        end
      else
        render json: {error: 'User already attended this activity'}.to_json, status: :unprocessable_entry
      end
    elsif @tag.claimed == true
      render json: {error: 'This tag was already claimed '}, status: :unprocessable_entry
    else
      if @user.award_points(event, event.cost_bb.nil? ? event.event.cost_bb : event.cost_bb, @tag.created_at.to_date.to_s)
        @tag.claimed = true
        @tag.user = @user
        @tag.save
        render json: {data: @user}, status: 200, location: @user
      else

        render json: {error: @user.errors.as_json(full_messages: true) }, status: :unprocessable_entity
      end
    end
  end

  def check_pin
    @user = User.friendly.find(params[:id])
    if @user.pin == Digest::MD5.hexdigest(params[:pin])
      render json: UserSerializer.new(@user).serialized_json
    else
      render json: {error: 'Incorrect PIN'}, status: 403
    end
  end

  def link_to_nfc
    @user = User.friendly.find(params[:id])
    # check for existing NFC
    existing = Nfc.find_by(tag_address: params[:tag_address])
    # logger.warn('looking for ' + params[:tag_address])
    # logger.warn('existing is ' + existing.inspect)
    if existing.nil?
      # logger.warn('linking nfc tag with id ' + params[:tag_address] + ' and security code ' + params[:securekey] + ' to user ' + @user.inspect)
      begin
        n = Nfc.new(tag_address: params[:tag_address], security_code: params[:securekey], active: true, keyholder: true)
        @user.nfcs << n
        n.save
        Activity.create(user: @user, item: n, addition: 0, description: 'linked')
        render json: {data: @user}, status: 200
      rescue
        # logger.warn("error")
        render json: {error: {user: @user, all: @user.errors.as_json(full_messages: true) }}, status: :unprocessable_entity
      end
    else
      # logger.warn('hash is ' + {errors: {message: 'Card already belongs to user ' + existing.user.username + " (#{existing.user.name})", user: existing.user}}.as_json.to_s)
      # {errors: [{message: 'Card already belongs to user ' + existing.user.username + " (#{existing.user.name})", user: existing.user}]}.as_json
      render json: {error: {message: 'That card already belongs to ' + existing.user.display_name, user: existing.user}} , status: :unprocessable_entity
    end
  end

  def resubmit
    # be very specific here

    @iu = InstancesUser.find_by(instance_id: params[:instance_id], id: params[:id], user_id: params[:user_id])
    if @iu.nil?
      render json: {error: 'Cannot find this instance/user'}, status: :unprocessable_entity
    else
      activity = @iu.activity
      ethtransaction = activity.ethtransaction
      if ethtransaction.nil?
        points = @iu.instance.cost_bb
      else
        points = ethtransaction.value
      end
      # logger.warn('attempting to resubmit to ' + @iu.user.accounts.first.address + ' for ' + points.to_s)
      api = BidappApi.new
      begin

        transaction = api.mint(@iu.user.accounts.first.address, points)
        @iu.user.accounts.first.balance = @iu.user.accounts.first.balance.to_i + points
        # logger.warn('new transaction is ' + transaction)
        sleep 3
        neweth = Ethtransaction.find_by(txaddress: transaction['data'])
        if neweth
          # ethtransaction.destroy
          activity.ethtransaction = neweth
          activity.save

          render json: {data: activity.ethtransaction}, status: 200
        else
          # logger.warn('new transaction is ' + transaction)
          # logger.warn('neweth should be ' + neweth.inspect)
          # logger.warn('error = ' + activity.errors.inspect)
          render json: {error: 'errors are ' + activity.errors.inspect }, status: :unprocessable_entity

        end

      rescue
        # don't write anything unless it goes to blockchain
        render json: {error: 'minting error'}, status: :unprocessable_entity
      end
    end

  end

  def respend
    @user = User.find(params[:id])
    api = BidappApi.new
    begin
      transaction = api.spend(@user.accounts.first.address, params[:points])
      sleep 2
      neweth = Ethtransaction.find_by(txaddress: transaction)
      if neweth
        render json: {data: neweth}, status: 200
      else
        render json: {error: 'Could not save ethtransaction'}, status: :unprocessable_entity
      end
    rescue
      render json: {error: 'spending error'}, status: :unprocessable_entity
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
      json: UserSerializer.new(users)
      )
  end


end
