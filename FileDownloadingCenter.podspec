#
# Be sure to run `pod lib lint FileDownloadingCenter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FileDownloadingCenter'
  s.version          = '1.0.0'
  s.summary          = 'File Downloading Center is an iOS downloading library for files.'
  s.description      = 'File Downloading Center is used for facilitating the files downloading and all its stuff from storing, restoring, displaying, ...'
  s.author       = { 'Amr Elsayed' => 'amrelsayed.mohamed@gmail.com' }
  
  s.platform     = :ios, '10.0'
  s.homepage         = 'https://github.com/amr-abdelfattah/FileDownloadingCenter'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.source           = { :git => 'https://github.com/amr-abdelfattah/FileDownloadingCenter.git', :tag => 'v' + s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5.1'
  
  s.source_files = 'FileDownloadingCenter/Classes/**/*'
  
  s.dependency 'ReachabilitySwift' , '~> 5.0'
  
  # s.resource_bundles = {
  #   'FileDownloadingCenter' => ['FileDownloadingCenter/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
