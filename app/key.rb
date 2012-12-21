module OAuth
  class Keychain
    def initialize(consumer_key)
      @keychain = HKKeychain.alloc.initWithConsumerKey(consumer_key)
    end

    def authorized?
      token = @keychain.retrieveOAuthTokenFromKeychain
      if token['oauth_token'] == nil || token['oauth_token_secret'] == nil
        false
      else
        true
      end
    end

    def fetch
      @keychain.retrieveOAuthTokenFromKeychain
    end

    def remove
      @keychain.removeOAuthTokenFromKeychain
    end

    def store(res)
      @keychain.token = res.oauth_token
      @keychain.tokenSecret = res.oauth_token_secret
      @keychain.screenName = res.screen_name
      @keychain.storeOAuthTokenInKeychain
    end
  end
end

