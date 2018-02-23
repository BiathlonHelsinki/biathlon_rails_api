class NfcsController < ApplicationController

  skip_before_action :authenticate_user!, raise: false
  before_action :authenticate_hardware!, only: [:unattached_users, :auth_door, :erase_tag]


  def auth_closet
    if params[:securekey] == '00000000'
      render json: {error: 'No security key on card'}, status: 401
    else
      @nfc = Nfc.find_by(tag_address: params[:id], security_code: params[:securekey])

    end
    if @nfc.nil?
      render json: {error: 'no card found in db!'}, status: 401
    else
      @nfc.update_attribute(:last_used, Time.current.utc)
      if @nfc.keyholder == true
        render json: {data: {access: 'BOTH', user: @nfc.user}}, status: 200
      elsif !Roombooking.find_by(day: Time.current.localtime.to_date).nil?
        if @nfc.user == Roombooking.find_by(day: Time.current.localtime.to_date).user
          render json: {data: {access: 'RENTAL', user: @nfc.user}}, status: 200
        else
          render json: {error: {message: 'This user has not rented this fucking room', user: @nfc.user}}, status: 401
        end
      else
        render json: {error: {message: 'No user found with this tag!'}}, status: 401
      end
    end
  end



  def auth_door
    if params[:id].length == 8
      @nfc = Nfc.find_by(tag_address: params[:id])
    elsif params[:securekey] == '00000000'
      render json: {error: 'No security key on card'}, status: 401
    else
      @nfc = Nfc.find_by(tag_address: params[:id], security_code: params[:securekey])
    end
    if @nfc.nil?
      render json: {error: 'no card found in db!'}, status: 401
    else
      @nfc.update_attribute(:last_used, Time.current.utc)
      if @nfc.keyholder == true
        render json: {data: @nfc.user}, status: 200
      elsif !Roombooking.find_by(day: Time.current.localtime.to_date).nil?
        if @nfc.user == Roombooking.find_by(day: Time.current.localtime.to_date).user
          render json: {data:@nfc.user}, status: 200
        else
          render json: {error: {message: 'This user has not rented this fucking room', user: @nfc.user}}, status: 401
        end
      else
        render json: {error: 'No user found with this tag!'}, status: 401
      end
    end
  end



  def unattached_users
    if params[:q].blank?
      @users = User.untagged.order(created_at: :desc)
    else
      @users = User.joins(:authentications).fuzzy_search({name: params[:q], email: params[:q], username: params[:q], authentications: { username: params[:q] }}, false)
      @users += User.where("lower(name) like '%" + params[:q].downcase + "%' OR lower(email)  LIKE '%" + params[:q].downcase + "%' OR lower(username) LIKE '%" + params[:q].downcase + "%'")
      @users.uniq!
    end
    render json: UserSerializer.new(@users).serialized_json, status: 200
  end

  def erase_tag
    @nfc = Nfc.find_by(tag_address: params[:id]) #, security_code: params[:securekey])
    if @nfc.nil?
      render json: {error: 'Card is already blank, or at least not in our database!'}, status: 401
    else
      if @nfc.destroy
        render json: @nfc, status: 200
      else
        render json: {error: 'No entry found for this tag!'}, status: 401
      end
    end
  end


  def user_from_tag
    if params[:securekey] != '00000000'
    #   render json: {error: 'no security code on tag!'}, status: 401
    # else
      @nfc = Nfc.find_by(tag_address: params[:id], security_code: params[:securekey])
    end
    if @nfc.nil?
      render json: {error: 'no security code on tag!'}, status: 401
    else
      @nfc.update_attribute(:last_used, Time.current.utc)
      if @nfc.user
        render json: @nfc.user, status: 200
      else
        render json: {error: 'No user found with this tag!'}, status: 401
      end
    end
  end

  def verify_tag

    if params[:securekey] == '00000000'
      render json: {error: 'no security code on tag!'}, status: 401
    elsif '0x' + params[:node_address] == Setting.first.options["contract_address"]
      a = Account.find_by(address: '0x' + params[:user_address]);
      @user = a.holder
      nfc = Nfc.find_by(user: @user, tag_address: params[:tag_address], security_code: params[:securekey])
      if nfc
        render json: {data: nfc.user}, status: 200
      else
        render json: {error: 'No user found with this tag!'}, status: 401
      end
    else
      #  deal with other nodes later
      render json: {error: 'Invalid Biathlon node!'}, status: 401
    end

  end

end
