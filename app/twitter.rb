module Twitter

  include OAuth::Helper
  include OAuth::Constant  

  def fetchTweet(text, &block)
    keychain = getKeychain.fetch
    if keychain['oauth_token'] == nil || keychain['oauth_token_secret'] == nil
      return
    end

    @items = []
    @req = OAuth::Request.new(
      consumer_key: CONSUMER_KEY,
      consumer_secret: CONSUMER_SECRET,
      access_token: keychain['oauth_token'], 
      access_token_secret: keychain['oauth_token_secret'],
    ) 

    @req.get("https://api.twitter.com/1.1/search/tweets.json",
             {q: text, include_entities: "1", count:"30"}) do |res|
      unless res.ok?
        block.call res
        return
      end

      error = Pointer.new(:object)
      json = NSJSONSerialization.JSONObjectWithData(res.body,
                                                    options:NSJSONReadingMutableContainers,
                                                    error:error)
      unless json
        raise error[0]
      end

      @reqs = Array.new
      size = json['statuses'].size
      json['statuses'].each_with_index do |tweet, i|
        next unless profile_image = tweet['user']['profile_image_url_https']
        @reqs[i] = HTTP::Request.new
        @reqs[i].get(profile_image) do |res|
          @reqs[i].cancel
          image = UIImage.imageWithData(res.body)
          @items[i] = tweet
          @items[i]['image'] = image
          block.call(res)
        end
      end
    end
  end
end

