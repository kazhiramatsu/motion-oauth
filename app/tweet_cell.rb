class TweetCell < UITableViewCell

  attr_accessor :tweetText, :userName, :profileImage

  def initWithStyle(style, reuseIdentifier:reuseIdentifier)
    if super

      @profileImage = UIImageView.alloc.init
      @profileImage.layer.masksToBounds = true
      @profileImage.layer.cornerRadius = 20

      self.addSubview @profileImage

      @tweetText = UILabel.alloc.init
      @tweetText.setFont(UIFont.systemFontOfSize(18))
      @tweetText.lineBreakMode = UILineBreakModeWordWrap
      @tweetText.numberOfLines = 0
      @tweetText.backgroundColor = UIColor.clearColor
      self.addSubview @tweetText

      @userName = UILabel.alloc.init
      @userName.setFont(UIFont.systemFontOfSize(16))
      @userName.backgroundColor = UIColor.clearColor
      self.addSubview @userName
    end
    self
  end

  def layoutSubviews
    return unless @tweetText.text
    return unless @userName.text
    @profileImage.frame = CGRectMake(30, 6, 28.5, 26.5)
 
    font = UIFont.systemFontOfSize(18)
    size = @tweetText.text.sizeWithFont(font,
                                        constrainedToSize:CGSizeMake(480, 100),
                                        lineBreakMode:UILineBreakModeCharacterWrap) 
    @tweetText.frame = CGRectMake(30, 45, size.width, size.height);

    font = UIFont.systemFontOfSize(16)
    size = @userName.text.sizeWithFont(font,
                                        constrainedToSize:CGSizeMake(100, 100),
                                        lineBreakMode:UILineBreakModeCharacterWrap) 

    @userName.frame = CGRectMake(60, 6, size.width, size.height);

  end
end
