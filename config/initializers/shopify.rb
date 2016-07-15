ShopifyAPI::Session.setup({api_key: Dynamica::Settings::Shopify.api_key, secret: Dynamica::Settings::Shopify.secret})

module ShopifyAPI
  class Session
    def request_token(params)
      return token if token

      code = params['code']

      response = access_token_request(code)

      if response.code == "200"
        token = JSON.parse(response.body)['access_token']
      else
        raise RuntimeError, response.msg
      end
    end
  end
end