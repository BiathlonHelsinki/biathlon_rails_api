class GroupsController < ApplicationController


  def get_eth_address
    @group = Group.friendly.find(params[:id])
    render json: {"address" => @group.get_eth_address}, status: 200
  end

  def get_balance
    @group = Group.friendly.find(params[:id])

    GetbalanceJob.perform_later @group
    render json: {data: @group.latest_balance}, status: 200
  end

end