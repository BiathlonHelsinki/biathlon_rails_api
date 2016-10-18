class NfcsController < ApplicationController

  skip_before_action :authenticate_user!, raise: false
  before_action :authenticate_hardware!, only: [:unattached_users, :erase_tag]
  
  def unattached_users
    if params[:q].blank?
      @users = User.untagged.order(created_at: :desc)
    else
      @users = User.joins(:authentications).fuzzy_search({name: params[:q], email: params[:q], username: params[:q], authentications: { username: params[:q] }}, false)
      @users += User.fuzzy_search(name: params[:q], username: params[:q])
      @users.uniq!
    end
    render json: @users, status: 200
  end
  
  def erase_tag
    @nfc = Nfc.find_by(tag_address: params[:id])
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
    if params[:securekey] == '00000000'
      @nfc = Nfc.find_by(tag_address: params[:id])
    else
      @nfc = Nfc.find_by(tag_address: params[:id], security_code: params[:securekey])
    end
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