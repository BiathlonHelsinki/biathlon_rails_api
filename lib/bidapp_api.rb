require 'httparty'

class BidappApi
  API_URL = Figaro.env.dapp_address

  def api_call(url = '/')
    response = HTTParty.get(API_URL + url)
    # TODO more error checking (500 error, etc)
    JSON.parse(response.body)['data']
  end
  
  def api_post(url = '/', options)
    begin
      response = HTTParty.post(API_URL + url, body: options)
      JSON.parse(response.body)['data']
    rescue HTTParty::Error => e
      JSON.parse({error: "Error from #{API_URL + url}: #{e}"}.to_json)
    rescue StandardError => e
      JSON.parse({error: "Error contacting #{API_URL}: #{e}"}.to_json)
    end
  end
  
  def mint(recipient, tokens) 
    response = HTTParty.post(API_URL + '/mint', body: {recipient: recipient, tokens: tokens} )
    JSON.parse(response.body)['data']
  end

  def spend(spender, tokens)
    response = HTTParty.post(API_URL + '/spend', body: {sender: spender, tokens: tokens} )
    JSON.parse(response.body)['data']
  end
  
  def transfer(sender, recipient, tokens, password) 
    response = HTTParty.post(API_URL + '/transfer', body: {sender: sender, recipient: recipient, tokens: tokens, unlock: password} )
    JSON.parse(response.body)['data']
  end
    
end