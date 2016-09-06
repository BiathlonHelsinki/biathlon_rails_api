class NfcsController < ApplicationController

  skip_before_action :authenticate_user!, raise: false
  # before_action :authenticate_hardware!, only: [:unattached_users]
  
  def unattached_users
    if params[:q].blank?
      @users = User.untagged
    else
      @users = User.joins(:authentications).fuzzy_search({name: params[:q], email: params[:q], username: params[:q], authentications: { username: params[:q] }}, false)
    end
    render json: UserSerializer.new(@users), status: 200
  end
  
  def user_from_tag
    @nfc = Nfc.find_by(tag_address: params[:id], security_code: params[:securekey])
    if @nfc.nil?
      render json: {error: 'no security code on tag!'}, status: 401
    else
      if @nfc.user
        render json: @nfc.user, status: 200
      else
        render json: {error: 'No user found with this tag!'}, status: 401
      end
    end
  end
    
end