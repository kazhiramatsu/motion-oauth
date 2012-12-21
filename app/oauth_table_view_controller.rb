class OAuthTableViewController < UITableViewController

  include OAuth::Helper
  include Twitter

  def init
    if super
      @items = [] 
    end
    self
  end

  def viewWillAppear(animated)
    super
  end

  def viewDidLoad
    super 
    self.navigationItem.rightBarButtonItem = setupButton("post", "handleRightBarButton")
  end

  def viewDidAppear(animated)
    if getKeychain.authorized?
      fetchTweet "#rubymotion" do |res|
        if res.ok?
          self.tableView.reloadData
        end
      end
    else
      presentOAuthView
    end
  end
   
  def textAtIndexPath(indexPath)
    unless @items.empty?
      item = @items[indexPath.row]
      return item['text'] unless item.nil?
    end
    return ""
  end

  def imageAtIndexPath(indexPath)
    unless @items.empty?
      item = @items[indexPath.row]
      item['image'] unless item.nil?
    end
  end

  def nameAtIndexPath(indexPath)
    unless @items.empty?
      item = @items[indexPath.row]
      item['user']['name'] unless item.nil?
    end
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    if text = textAtIndexPath(indexPath) 
      font = UIFont.systemFontOfSize(18)
      size = text.sizeWithFont(font,
                               constrainedToSize:CGSizeMake(480, 100),
                               lineBreakMode:UILineBreakModeCharacterWrap) 
      size.height + 35 + 35 
    else
      0
    end
  end

  def numberOfSectionsInTableView(tableView)
    1  
  end
  
  def tableView(tableView, numberOfRowsInSection:section) 
    @items.size 
  end
 
  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cellIdentifier = "Cell#{indexPath.row}"
    cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
    
    unless cell
      cell = TweetCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellIdentifier) 
    end

    cell.userName.text = nameAtIndexPath(indexPath) 
    cell.profileImage.image = imageAtIndexPath(indexPath)
    cell.tweetText.text = textAtIndexPath(indexPath) 
    cell
  end
 
  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
  end

  def handleRightBarButton
    presentWriteView 
  end

end
