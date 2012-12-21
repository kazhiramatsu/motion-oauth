
class OAuthViewController < UIViewController

  include OAuth::Helper
  include OAuth::Constant

  def viewDidLoad
    super

    setupLeftBarButton

    @first = true

    @consumer = OAuth::Consumer.new(
      consumer_key: CONSUMER_KEY,
      consumer_secret: CONSUMER_SECRET,
      request_token_url: REQUEST_TOKEN_URL,
      authorize_url: AUTHORIZE_URL,
      access_token_url: ACCESS_TOKEN_URL,
    )

    @consumer.get_request_token do |res|
      if res.ok?
        webView = UIWebView.alloc.initWithFrame(self.view.bounds)
        webView.delegate = self;
        self.view.addSubview(webView)
        request = NSURLRequest.requestWithURL(NSURL.URLWithString(res.authorize_url))
        webView.loadRequest(request)
      end
    end
  end

  def webViewDidFinishLoad(webView)

    if @first
      @first = false
      return
    end

    verifier = @consumer.get_verifier(webView)
    if verifier == nil
      self.dismissViewControllerAnimated(true, completion:nil)
      return
    end

    @consumer.get_access_token(verifier) do |res|
      getKeychain.store(res)
      self.dismissViewControllerAnimated(true, completion:nil)
    end
  end

  def handleLeftBarButton
    self.dismissViewControllerAnimated(true, completion:nil)
  end
end

