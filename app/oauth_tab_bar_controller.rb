class OAuthTabBarController < UITabBarController 

  def init 
    if super

      @oauthTableViewController = OAuthTableViewController.alloc.init 
      @oauthTableNaviController = UINavigationController.alloc.initWithRootViewController(@oauthTableViewController)

      viewControllers = Array.new
      viewControllers.push(@oauthTableNaviController)

      self.setViewControllers(viewControllers)
    end
    self
  end

end
