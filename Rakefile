# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'motion-oauth'
  app.entitlements['keychain-access-groups'] = [
    app.seed_id + '.' + app.identifier
  ]
  app.vendor_project('vendor/HMACSHA1', :xcode, headers_dir: 'HMACSHA1')
  app.vendor_project('vendor/Keychain', :xcode, headers_dir: 'Keychain')
  app.detect_dependencies = false

  app.files.unshift('./app/tweet_cell.rb') 
  app.files.unshift('./app/twitter.rb') 
  app.files.unshift('./app/oauth.rb') 
  app.files.unshift('./app/http.rb') 
  app.files.unshift('./app/helper.rb') 
  app.files.unshift('./app/key.rb') 
  app.files.unshift('./app/constant.rb') 
end
