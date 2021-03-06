#
# Be sure to run `pod lib lint FileDownloadingCenter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FileDownloadingCenter'
  s.version          = '1.1.4'
  s.summary          = 'File Downloading Center is an iOS downloading library for files.'
  s.description      = 'File Downloading Center is used for facilitating the files downloading and all its stuff from storing, restoring, displaying, ...'
  s.author       = { 'Amr Elsayed' => 'amrelsayed.mohamed@gmail.com' }
  s.homepage         = 'https://github.com/amr-abdelfattah/iOS-FileDownloadingCenter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.source           = { :git => 'https://github.com/amr-abdelfattah/iOS-FileDownloadingCenter.git', :tag => s.version }

  s.ios.deployment_target = '10.0'
  s.watchos.deployment_target = '5.0'
  s.swift_version = '5.1'
  
  s.source_files = 'FileDownloadingCenter/Classes/**/*'

end
