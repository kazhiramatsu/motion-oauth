module OAuth
  module Helper
    def getKeychain
      UIApplication.sharedApplication.delegate.keychain
    end

    def setupButton(title, action)
      buttonItem = UIBarButtonItem.alloc.initWithTitle(
        title,
        style:UIBarButtonItemStylePlain,
        target:self,
        action:action
      )
    end

    def setupRightBarButton
      self.navigationItem.rightBarButtonItem = setupButton("post", "handleRightBarButton")
    end

    def setupLeftBarButton
      self.navigationItem.leftBarButtonItem = setupButton("cancel", "handleLeftBarButton")
    end

    def presentOAuthView 
      @oauthViewController = OAuthViewController.alloc.init
      @oauthNaviController = UINavigationController.alloc.initWithRootViewController(@oauthViewController)
      self.presentViewController(@oauthNaviController, animated: true, completion: nil)
    end

    def presentWriteView 
      @writeViewController = WriteViewController.alloc.init
      @writeNaviController = UINavigationController.alloc.initWithRootViewController(@writeViewController)
      self.presentViewController(@writeNaviController, animated: true, completion: nil)
    end

  end
end
