
module OAuth 

  module Util

    def make_request_params(sig_params, quote='')
      req_params = []
      sig_params.sort.each do |k,v|
        p = urlencode(k.to_s) + '=' + quote + urlencode(v.to_s) + quote
        req_params.push(p)
      end
      req_params
    end

    def make_default_params(params)
      params[:oauth_consumer_key] = @consumer_key
      params[:oauth_nonce] = rand(10 ** 30).to_s.rjust(32,'0').to_s
      params[:oauth_signature_method] = @signature_method || 'HMAC-SHA1' 
      params[:oauth_timestamp] = Time.now.to_i.to_s
      params[:oauth_version] = "1.0" 
      params
    end

    def make_signature(method, url, params)
      sig_array = []
      params.sort.each do |k, v|
        p = urlencode(k.to_s) + '=' + urlencode(v.to_s)
        sig_array.push(p)
      end

      message = sig_array.join('&')
      data = [method, urlencode(url), urlencode(message)].join('&')

      key = make_key 
      signature = [HMACSHA1.digest(key,message:data)].pack('m0')

      # require 'openssl'
      # d = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA1.new, key, data)
      # sig =  [d].pack('m0') 
    end

    def urlencode(text)
      return "" if text.nil?
      escapes = {}
      (0..255).each do |val|
        escapes[val.chr] = sprintf("%%%02X", val)
      end
      result = text.gsub(/([^A-Za-z0-9\-._~])/, escapes)
      result
    end

  end

  class Request < HTTP::Request

    attr_accessor :consumer_key, :consumer_secret,
                  :access_token, :access_token_secret

    include OAuth::Util

    def initialize(args)
      super
      @consumer_key = args[:consumer_key] or raise "missing consumer_key"
      @consumer_secret = args[:consumer_secret] or raise "missing consumer_secret"
      @access_token = args[:access_token]
      @access_token_secret = args[:access_token_secret]
    end

    def make_key
      key = @consumer_secret + '&' + @access_token_secret
      key
    end

    def make_authorization_header(params)
      sig_array = make_request_params(params, '"')
      "OAuth " + sig_array.join(', ')
    end

    def multipart_post(url, params, &block)
      boundary = "absckdld2039949999rfjgj" 
      sig_params = make_signature_params('POST', url, {})
      auth_header = make_authorization_header(sig_params)
      headers = {
        'Authorization' => auth_header,
        'Content-type' => "multipart/form-data; boundary=#{boundary}",
      }

      super(url, headers, params, boundary, &block)
    end

    def make_signature_params(method, url, params)
      sig_params = params.dup
      sig_params = make_default_params(sig_params)
      sig_params[:oauth_token] = @access_token
      sig_params[:oauth_signature] = make_signature(method, url, sig_params)
      sig_params.delete_if do |k|
        params.include?(k) 
      end
      sig_params
    end

    def post(url, params, &block)
      sig_params = make_signature_params('POST', url, params)
      auth_header = make_authorization_header(sig_params)
      headers = {
        'Authorization' => auth_header,
        'Content-Type' => 'application/x-www-form-urlencoded',
      }

      super(url, headers, params, &block)
    end

    def get(url, params, &block)
      sig_params = make_signature_params('GET', url, params)
      auth_header = make_authorization_header(sig_params)
      headers = {
        'Authorization' => auth_header,
      }

      super(url, headers, params, &block)
    end
  end

  class Consumer

    attr_accessor :consumer_key, :cunsumer_secret, :request_token_url,
                  :authorize_url, :verifier

    include OAuth::Util

    class Response
      attr_accessor :status_code, :oauth_token, :oauth_token_secret,
                    :authorize_url, :screen_name, :consumer_key

      def initialize(args)
        @ok = args[:ok] || false
        @status_code = args[:status_code] || 200
        @oauth_token = args[:oauth_token] || "" 
        @oauth_token_secret = args[:oauth_token_secret] || ""
        @authorize_url = args[:authorize_url] || ""
        @screen_name = args[:screen_name] || ""
        @consumer_key = args[:consumer_key] 
      end

      def ok?
        @ok
      end
    end

    class Connection  
      attr_accessor :status_code, :oauth_token, :oauth_token_secret,
        :authorize_url, :screen_name, :connection, :body, :callback

      def initialize(args)
        @ok = args[:ok] || false
        @status_code = args[:status_code] || 200
        @body = args[:body] || NSMutableData.data 
        @oauth_token = args[:oauth_token] || "" 
        @oauth_token_secret = args[:oauth_token_secret] || ""
        @authorize_url = args[:authorize_url] || ""
        @screen_name = args[:screen_name] || ""
        @callback = args[:callback] || nil 
        @consumer_key = args[:consumer_key]
      end

      def parse_token 
        str = NSString.alloc.initWithBytes(
          @body.bytes,
          length:@body.length,
          encoding:NSASCIIStringEncoding
        )
        res = Hash.new
        str.split('&').each do |a|
          part = a.split('=')
          res[part[0]] = part[1] 
        end
        @oauth_token = res["oauth_token"]
        @oauth_token_secret = res["oauth_token_secret"]
        @screen_name = res["screen_name"] || ""
      end

      def connection(connection, didReceiveResponse:response)
        @status_code = response.statusCode
      end

      def connection(connection, didReceiveData:data)
        @body.appendData data
      end

      def connectionDidFinishLoading(connection)
        connection.cancel
        @ok = true
        parse_token
        @authorize_url = "#{@authorize_url}?oauth_token=#{@oauth_token}" if @authorize_url
        res = Response.new(
          ok: @ok,
          status_code: @status_code,
          consumer_key: @consumer_key,
          oauth_token: @oauth_token,
          oauth_token_secret: @oauth_token_secret,
          authorize_url: @authorize_url,
          screen_name: @screen_name
        ) 
        callback.call(res)
      end

      def connection(connection, didFailWithError:error)
        connection.cancel
      end

    end


    def initialize(args)
      options = [ :consumer_key, :consumer_secret, :request_token_url,
        :authorize_url, :access_token_url ]
      args.each do |k, v|
        raise ArgumentError unless options.include?(k)
      end
      @consumer_key = args[:consumer_key]
      @consumer_secret = args[:consumer_secret]
      @signature_method = args[:signature_method] || 'HMAC-SHA1'
      @request_token_url = args[:request_token_url]
      @authorize_url = args[:authorize_url]
      @access_token_url = args[:access_token_url]
      @request_token_connection = nil
      @access_token_connection = nil
      @request_token_delegate = Connection.new(authorize_url: @authorize_url,
                                               consumer_key:@consumer_key)
      @access_token_delegate = Connection.new(status: 200,
                                              consumer_key:@consumer_key)
      @verifier = ""
    end

    def make_key
      key = @consumer_secret + '&' + @request_token_delegate.oauth_token_secret
    end


    def get_request_token(url = nil, &block)
      raise ArgumentError unless block_given?

      @request_token_url = url ? url : @request_token_url 
      @request_token_delegate.callback = block

      sig_params = {}
      sig_params = make_default_params(sig_params)
      sig_params[:oauth_signature] = make_signature('GET', @request_token_url, sig_params)

      req_params = make_request_params(sig_params) 
      request_token_url = @request_token_url + '?' +  req_params.join('&')

      request = NSURLRequest.requestWithURL(NSURL.URLWithString(request_token_url))
      @request_token_connection = NSURLConnection.alloc.initWithRequest(request, delegate:@request_token_delegate)
    end

    def get_access_token(verifier, url = nil, &block)

      @verifier = verifier 
      @access_token_delegate.callback = block

      sig_params = {}
      sig_params = make_default_params(sig_params)
      sig_params[:oauth_verifier] = @verifier
      sig_params[:oauth_token] = @request_token_delegate.oauth_token 
      sig_params[:oauth_signature] = make_signature('GET', @access_token_url, sig_params)

      req_params = make_request_params(sig_params)

      access_token_url = @access_token_url + '?' + req_params.join('&')
      request = NSURLRequest.requestWithURL(NSURL.URLWithString(access_token_url))
      @access_token_connection = NSURLConnection.alloc.initWithRequest(request, delegate:@access_token_delegate)
    end

    def get_verifier(webView)
      js = "var d = document.getElementById('oauth-pin'); if (d == null) d = document.getElementById('oauth_pin'); if (d) d = d.innerHTML; d;"
      pin = webView.stringByEvaluatingJavaScriptFromString(js).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet)

      if pin.length == 7
        return pin
      else
        # New version of Twitter PIN page
        js = "var d = document.getElementById('oauth-pin'); if (d == null) d = document.getElementById('oauth_pin'); " \
          "if (d) { var d2 = d.getElementsByTagName('code'); if (d2.length > 0) d2[0].innerHTML; }"
        pin = webView.stringByEvaluatingJavaScriptFromString(js).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet)

        if pin.length == 7
          return pin;
        end

      end 
      nil
    end

  end

end
