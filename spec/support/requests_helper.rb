module Requests
  module JsonHelpers
    def json
      @json ||= JSON.parse(response.body, symbolize_names: true)
    end

    def token_header(token)
      ActionController::HttpAuthentication::Token.encode_credentials(token)
    end

    # Adds user's authorization data to the headers
    # @param [User] user
    # @param [Hash] original headers
    # @return [Hash] headers with user's authorization data
    def user_headers(user, headers)
      headers.merge({ 'Authorization' => token_header(user.api_token) })
    end
  end
end
