require 'httparty'

class BidappApi
  API_URL = Figaro.env.dapp_address

  def api_call(url = '/')
    response = HTTParty.get(API_URL + url, timeout: 4)
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
  
  def api_post(url = '/', options)
    begin
      response = HTTParty.post(API_URL + url, body: options, timeout: 4)
      JSON.parse(response.body)['data']
    rescue HTTParty::Error => e
      JSON.parse({error: "Error from #{API_URL + url}: #{e}"}.to_json)
    rescue StandardError => e
      JSON.parse({error: "Error contacting #{API_URL}: #{e}"}.to_json)
    end
  end
  
  def confirm(txhash)
    response = HTTParty.post(API_URL + '/check_transaction', body: {txhash: txhash }, timeout: 4 )
    return response.body
  end
  
  def mint(recipient, tokens) 
    response = HTTParty.post(API_URL + '/mint', body: {recipient: recipient, tokens: tokens}, timeout: 4 )
    begin
      JSON.parse(response.body)
    rescue e
      return e
    end
  end

  def spend(spender, tokens)
    response = HTTParty.post(API_URL + '/spend', body: {sender: spender, tokens: tokens}, timeout: 4 )
    begin
      JSON.parse(response.body)
    rescue e
      return e
    end
    # JSON.parse(response.body)['data']
  end
  
  def transfer_user(sender, recipient, tokens, password) 
    begin
      response = HTTParty.post(API_URL + '/transfer', body: {sender: sender, recipient: recipient, tokens: tokens, unlock: password}, timeout: 3 )
      return response.body

    rescue HTTParty::Error => e
      JSON.parse({error: "Error from #{API_URL + url}: #{e}"}.to_json)
    rescue StandardError => e
      JSON.parse({error: "Error contacting #{API_URL}: #{e}"}.to_json)
    end
  end
  
  def transfer(sender, recipient, tokens) 
    response = HTTParty.post(API_URL + '/transfer_owner', body: {sender: sender, recipient: recipient, tokens: tokens }, timeout: 3 )
    return response.body
  end  
end