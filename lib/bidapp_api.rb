require 'httparty'


class BidappApi
  API_URL = Figaro.env.dapp_address

  
  def api_call(url = '/')
    response = HTTParty.get(API_URL + url, timeout: 12)
    # TODO more error checking (500 error, etc)
    begin
      if response.body['error']
        JSON.parse(response.body)['error']
      else
        JSON.parse(response.body)['data']
      end
    rescue e
      return e
    end
  end
  
  def get_balance(address)
    begin
      response = HTTParty.get(API_URL + '/get_account_balance', {query: {account: address}, timeout: 10})
      JSON.parse(response.body)
    rescue => e
      return e.inspect
    end
  end

  def api_post(url = '/', options)
    begin
      response = HTTParty.post(API_URL + url, body: options, timeout: 12)
      JSON.parse(response.body)
    rescue HTTParty::Error => e
      JSON.parse({error: "Error from #{API_URL + url}: #{e}"}.to_json)
    rescue StandardError => e
      JSON.parse({error: "Error contacting #{API_URL}: #{e}"}.to_json)
    end
  end
  
  def confirm(txhash)
    response = HTTParty.get(API_URL + '/check_transaction',  {query: {txhash: txhash }, timeout: 6 })
    return response.body
  end
  
  def mint(recipient, tokens, blockchainid = nil)
    # logger = ActiveSupport::Logger.new(STDOUT)
    # logger.level = :info
    response = HTTParty.post(API_URL + '/mint', body: {recipient: recipient, tokens: tokens, blockchainid: blockchainid}, timeout: 40 )
    # logger.info('mint output is ' + response.body.inspect)
    json = JSON.parse(response.body)
    begin
      if json['success']
        return json
      else
        return {status: 'error', message: json['message']}.as_json
      end
    rescue e
      return e
    end
  end

  def spend(spender, tokens, blockchainid = nil)
    response = HTTParty.post(API_URL + '/spend', body: {sender: spender, tokens: tokens, blockchainid: blockchainid}, timeout: 40 )
    begin
      JSON.parse(response.body)
    rescue e
      return e
    end
    # JSON.parse(response.body)['data']
  end
  
  def transfer_user(sender, recipient, tokens, password) 
    begin
      response = HTTParty.post(API_URL + '/transfer', body: {sender: sender, recipient: recipient, tokens: tokens, unlock: password}, timeout: 12 )
      return JSON.parse(response.body)

    rescue HTTParty::Error => e
      JSON.parse({error: "Error from #{API_URL + url}: #{e}"}.to_json)
    rescue StandardError => e
      JSON.parse({error: "Error contacting #{API_URL}: #{e}"}.to_json)
    end
  end
  
  def transfer(sender, recipient, tokens, blockchainid = nil) 
    response = HTTParty.post(API_URL + '/transfer', body: {sender: sender, recipient: recipient, tokens: tokens, blockchainid: blockchainid }, timeout: 40 )
    return JSON.parse(response.body)
  end  
end