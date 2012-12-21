class WriteViewController < UIViewController

  include OAuth::Constant
  include OAuth::Helper

  def viewDidLoad
    super

    setupRightBarButton

    self.view.backgroundColor = UIColor.whiteColor
    tb = UIToolbar.alloc.initWithFrame(CGRectMake(0, 156, self.view.frame.size.width, 44))
    tb.tintColor = UIColor.darkGrayColor

    items = Array.new
    items.push(UIBarButtonItem.alloc.initWithBarButtonSystemItem(
      UIBarButtonSystemItemCamera,
      target:self,
      action:"handleImageAlbum")
    )

    tb.items = items 

    @textView = UITextView.alloc.initWithFrame(CGRectMake(5, 5, 200, 140));
    @textView.editable = true
    @textView.backgroundColor = UIColor.clearColor
    @textView.becomeFirstResponder
    @textView.delegate = self
    @textView.inputAccessoryView = tb 
    self.view.addSubview @textView 
  end

  def handleImageAlbum
    imagePickerController = UIImagePickerController.alloc.init
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum
    imagePickerController.delegate = self
    self.presentViewController(imagePickerController, animated: true, completion: nil)

  end

  def imagePickerController(picker, didFinishPickingMediaWithInfo:info)
    @pickingImage = info.objectForKey(UIImagePickerControllerOriginalImage)  
    UIImageWriteToSavedPhotosAlbum(@pickingImage, self, 'image:didFinishSavingWithError:contextInfo:',nil)
  end

  def viewWillAppear(animated)
    super
    if @picked 
      @imageView.removeFromSuperview if @imageView
      @imageView = UIImageView.alloc.initWithImage(@pickingImage)
      @imageView.frame = CGRectMake(0, 0, 320, 200)
      self.view.insertSubview(@imageView, belowSubview:@textView) 
    end
  end

  def image(image, didFinishSavingWithError:error, contextInfo:contextInfo)
    @picked = true
    self.dismissViewControllerAnimated(true, completion:nil)
  end

  def handleRightBarButton
    keychain = getKeychain.fetch
    @request = OAuth::Request.new(
      consumer_key: CONSUMER_KEY,
      consumer_secret: CONSUMER_SECRET,
      access_token: keychain['oauth_token'], 
      access_token_secret: keychain['oauth_token_secret'],
    )
    if @picked
      imageData = NSData.alloc.initWithData(UIImageJPEGRepresentation(@pickingImage, 0.5))
      @request.multipart_post("https://api.twitter.com/1.1/statuses/update_with_media.json",
                              {status: @textView.text, 'media[]' => imageData}) do |res|
      end
    else
      params = {
        status: @textView.text,
      }
      @request.post('https://api.twitter.com/1.1/statuses/update.json',
                    params) do |res|
        unless res.ok?
        end
      end
    end
    self.dismissViewControllerAnimated(true, completion:nil)
  end

  def handleLeftBarButton
    self.dismissViewControllerAnimated(true, completion:nil)
  end

end
