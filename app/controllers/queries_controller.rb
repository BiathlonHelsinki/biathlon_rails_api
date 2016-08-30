class QueriesController < ApplicationController
  
  skip_before_filter :authenticate_user!, raise: false
  
  def total_supply
    api = BidappApi.new
    api_data = api.api_call
    render json: api_data['totalSupply'], status: 200
  end
  
end