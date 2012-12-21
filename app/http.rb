module HTTP
  class Response
    attr_reader :status_code, :body
    def initialize(args)
      @ok = args[:ok] 
      @status_code = args[:status_code]
      @body = args[:body]
    end

    def ok?
      @ok
    end
  end

  class Request
    def initialize(args={})
      @status_code = 200
      @body = NSMutableData.data
    end

    def reachable?
      curReach = Reachability.reachabilityForInternetConnection
      netStatus = curReach.currentReachabilityStatus
      case (netStatus)
      when NotReachable
      when ReachableViaWWAN
      when ReachableViaWiFi
        return true
      else
        return false   
      end
    end

    def set_headers(request, headers)
      unless headers.empty?
        headers.each do |k,v|
          request.setValue(v.to_s, forHTTPHeaderField:k.to_s)
        end
      end
    end

    def make_query(params)
      return nil if params.empty?
      req_params = []
      params.each do |k,v|
        p = k.to_s + '=' + urlencode(v.to_s)
        req_params.push(p)
      end
      query = req_params.join('&')
    end

    def make_url(url, params) 
      query = make_query(params)
      if query
        url += '?' + query
      else
        url
      end
      url
    end

    def new_request(url, method='GET', headers={}, params={}, options={})
      if method == 'GET'
        url = make_url(url, params)
      end
      request = NSMutableURLRequest.requestWithURL(NSURL.URLWithString(url))
      request.setHTTPMethod(method)
      unless headers.empty?
        headers.each do |k,v|
          request.setValue(v.to_s, forHTTPHeaderField:k.to_s)
        end
      end
      if method == 'POST'
        if options[:is_multipart]
          raise "missing boundary" unless options[:boundary]
          body = make_multipart_body(params, options[:boundary])
          request.setHTTPBody(body) unless body.nil?
        else
          body = make_query(params)
          request.setHTTPBody(body.dataUsingEncoding(NSUTF8StringEncoding)) unless body.nil?
        end
      end
      request
    end

    def get(url, headers={}, params={}, &block)
      request = new_request(url, 'GET', headers, params)
      @connection = NSURLConnection.alloc.initWithRequest(request, delegate:self)
      @block = block
    end

    def make_multipart_body(params, boundary)

      postBody = NSMutableData.data

      params.each do |k,v|
        if v.is_a? NSData
          data = "--#{boundary}\r\n"
          data += "Content-Disposition: form-data; name=\"#{k.to_s}\"\r\n"
          data += "Content-Type: application/octet-stream\r\n\r\n"
          postBody.appendData(data.dataUsingEncoding(NSUTF8StringEncoding))
          postBody.appendData(v)
          postBody.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding))
        else
          data = "--#{boundary}\r\n"
          data += "Content-Disposition: form-data; name=\"#{k.to_s}\"\r\n\r\n"
          data += v.to_s 
          data += "\r\n"
          postBody.appendData(data.dataUsingEncoding(NSUTF8StringEncoding))
        end
      end

      postBody.appendData("--#{boundary}--\r\n".dataUsingEncoding(NSUTF8StringEncoding))
      postBody
    end

    def multipart_post(url, headers, params, boundary, &block)
      @block = block
      options = {
        is_multipart: true,
        boundary: boundary
      }
      request = new_request(url, 'POST', headers, params, options)
      @connection = NSURLConnection.alloc.initWithRequest(request, delegate:self)
    end

    def post(url, headers, params, &block)
      @block = block
      request = new_request(url, 'POST', headers, params)
      @connection = NSURLConnection.alloc.initWithRequest(request, delegate:self)
    end

    def connection(connection, didReceiveResponse:response)
      @status_code = response.statusCode
    end

    def connection(connection, didReceiveData:data)
      @body.appendData data
    end

    def connectionDidFinishLoading(connection)
      connection.cancel
      res = HTTP::Response.new(
        ok: true,
        status_code: @status_code,
        body: @body
      )
      @block.call(res)
    end

    def connection(connection, didFailWithError:error)
      connection.cancel
    end

    def cancel
      @connection.cancel
    end
  end
end
