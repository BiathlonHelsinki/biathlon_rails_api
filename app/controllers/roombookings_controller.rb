class RoombookingsController < ApplicationController
  

  before_action :authenticate_user!

  def create
    @user = User.find(params[:user_id])
    @current_rate = Rate.get_current
    @roombooking = Roombooking.new(user: @user, rate: @current_rate, day: params[:day], purpose: params[:purpose])
    # api = BidappApi.new
    @user.update_balance_from_blockchain
    if @user.latest_balance < @current_rate.room_cost
      render json: { error: 'You do not have enough Temps to do this'}, status: 400
    else
      begin

        # NEW: Queue this shit for processing later
        b = BlockchainTransaction.new( value: @current_rate.room_cost, account: @user.accounts.first, transaction_type: TransactionType.find_by(name: 'Spend'))
        a =  Activity.new(user: @user, item: @roombooking,
                            addition: -1,  description: "booked the back room on ",
                      extra_info: params[:purpose].blank? ? nil : " (for: #{params[:purpose]})", blockchain_transaction: b )
        
        if @roombooking.save
            @roombooking.activities << a
            a.save
            BlockchainHandlerJob.perform_later b
            @user.latest_balance = @user.latest_balance - @current_rate.room_cost
            @user.save

          render json: {data: @roombooking}, status: 200
        else
           logger.warn 'err:' + a.errors.inspect
          return {"error" => "error", "message" => b.errors.inspect}
        end
        
        # old code below
        # transaction = api.spend(@user.accounts.first.address, @current_rate.room_cost)

        # if transaction['error']
#           render json: {error: transaction['error']}, status: 400
#         else
#           sleep 2
#           et = Ethtransaction.find_by(txaddress: transaction['data'])
#           @roombooking.ethtransaction = et
#           if @roombooking.save
#             a = Activity.create(user: @user, item: @roombooking,
#               ethtransaction: et, addition: -1, txaddress: transaction['data'],
#               description: "booked the back room on ",
#               extra_info: params[:purpose].blank? ? nil : " (for: #{params[:purpose]})"
#             )
#             @user.update_balance_from_blockchain
#             render json: {data: transaction['data']}, status: 200
#           else
#             render json: {error: @roombooking.errors.inspect }, status: :unprocessable_entity
#           end

      rescue => e
        render json: {error: e.inspect }, status: :unprocessable_entity
      end 
    end 
  end
  
end