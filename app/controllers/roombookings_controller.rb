class RoombookingsController < ApplicationController
  

  before_action :authenticate_user!

  def create
    @user = User.find(params[:user_id])

    @roombooking = Roombooking.new(user: @user, booker_type: params[:booker_type], booker_id: params[:booker_id], points_needed: params[:cost], day: params[:start_at].to_date, start_at: params[:start_at], end_at: params[:end_at], purpose: params[:purpose])
    # api = BidappApi.new
    @user.update_balance_from_blockchain
    if @user.latest_balance < params[:cost].to_i
      render json: { error: 'You do not have enough points to do this'}, status: 400
    else
      begin

        # NEW: Queue this shit for processing later
        b = BlockchainTransaction.new( value: params[:cost], account: @user.accounts.first, transaction_type: TransactionType.find_by(name: 'Spend'))
        a =  Activity.new(user: @user, contributor: @user, item: @roombooking,
                            addition: -1,  description: "booked_the_back_room_on",
                      extra_info: params[:purpose].blank? ? nil : " (for: #{params[:purpose]})", blockchain_transaction: b )
        
        if @roombooking.save
            @roombooking.activities << a
            a.save
            BlockchainHandlerJob.perform_later b
            @user.latest_balance = @user.latest_balance -  @roombooking.points_needed
            @user.save

          render json: {data: @roombooking}, status: 200
        else
          logger.warn 'err:' + a.errors.inspect

          render json: {"error" => "error", "message" => @roombooking.errors.full_messages}, status: 400
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
        logger.warn(e.inspect)
        render json: {error: e.inspect }, status: :unprocessable_entity
      end 
    end 
  end
  
end