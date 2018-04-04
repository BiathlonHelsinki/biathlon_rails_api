class QueriesController < ApplicationController

  skip_before_action :authenticate_user!, raise: false

  def contract_address
    # get from DB, that is better
    s = Setting.first

    render json: {data: s.options.slice(*s.options.keys.delete_if{|x| x =~ /abi$/ }) }
  end

  def total_supply
    api = BidappApi.new
    api_data = api.api_call
    render json: api_data['totalSupply'], status: 200
  end

end
