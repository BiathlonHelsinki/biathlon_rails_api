class NfcsController < ApplicationController

  skip_before_action :authenticate_user!, raise: false
  before_action :authenticate_hardware!, only: [:unattached_users]
  
  def unattached_users
    if params[:q].blank?
      @users = User.untagged
    else
      @users = User.joins(:authentications).fuzzy_search({name: params[:q], email: params[:q], username: params[:q], authentications: { username: params[:q] }}, false)
    end
    render json: @users, status: 200
  end
  
  def user_from_tag
    @nfc = Nfc.find_by(tag_address: params[:id])
    if @nfc.nil?
      render json: {message: 'no card found!'}, status: 401
    else
      if @nfc.user
        render json: @nfc.user, status: 200
      end
    end
  end
    
end