#
# Be sure to run `pod lib lint DragNDrop.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DragNDrop'
  s.version          = '0.1.0'
  s.summary          = 'Enables an easy and fast way to move around items between tableViews.'

  s.description      = 'Enables an easy and fast way to move around items between tableViews. One can select a cell, drag it on top of another or the same tableView and drop it.'

  s.homepage         = 'https://github.com/lopes710/DragNDrop'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Duarte Lopes' => 'duarte.lopes85@gmail.com' }
  s.source           = { :git => 'https://github.com/lopes710/DragNDrop.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'DragNDrop/Classes/**/*'
  
  # s.resource_bundles = {
  #   'DragNDrop' => ['DragNDrop/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
