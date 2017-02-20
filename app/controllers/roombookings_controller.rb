class RoombookingsController < ApplicationController
  

  before_action :authenticate_user!

  def create
    @user = User.find(params[:user_id])
    @current_rate = Rate.get_current
    @roombooking = Roombooking.new(user: @user, rate: @current_rate, day: params[:day], purpose: params[:purpose])
    api = BidappApi.new
    begin
     
      transaction = api.spend(@user.accounts.first.address, @current_rate.room_cost)

      if transaction['error']
        render json: {error: transaction['error']}, status: 400
      else
        sleep 2
        et = Ethtransaction.find_by(txaddress: transaction['data'])
        @roombooking.ethtransaction = et
        if @roombooking.save
          a = Activity.create(user: @user, item: @roombooking,
            ethtransaction: et, addition: -1, txaddress: transaction['data'],
            description: "booked the back room on ", 
            extra_info: params[:purpose].blank? ? nil : " (for: #{params[:purpose]})"
          )
          render json: {data: transaction['data']}, status: 200
        else
          render json: {error: @roombooking.errors.inspect }, status: :unprocessable_entity
        end
      end
    rescue => e
      logger.warn('txdadta is ' + et.inspect + ' and errs are ' + e.inspect)
      render json: {error: e.inspect }, status: :unprocessable_entity
    end  
  end
  
end