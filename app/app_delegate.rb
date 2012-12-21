class AppDelegate

  include OAuth::Constant

  attr_accessor :keychain

  def application(application, didFinishLaunchingWithOptions:launchOptions)

    @keychain = OAuth::Keychain.new(CONSUMER_KEY)

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    @tabBarController = OAuthTabBarController.alloc.init

    @window.setRootViewController(@tabBarController)
    @window.makeKeyAndVisible
    true
  end

end
