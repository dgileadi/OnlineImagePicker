Pod::Spec.new do |s|
  s.name             = "OnlineImagePicker"
  s.version          = "0.1.0"
  s.summary          = "An image picker for iOS that allows choosing images from online services like Facebook, Instagram and Flickr as well as from the photo library."
  s.homepage         = "https://github.com/dgileadi/OnlineImagePicker"
  s.license          = 'MIT'
  s.author           = { "David Gileadi" => "gileadis@gmail.com" }
  s.source           = { :git => "https://github.com/dgileadi/OnlineImagePicker.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'OnlineImagePicker/**'

  s.public_header_files = 'OnlineImagePicker/**/*.h'
  s.frameworks = 'UIKit'
  s.dependency 'Dropbox-iOS-SDK'
  s.dependency 'Facebook-iOS-SDK'
  s.dependency 'FlickrKit'
  s.dependency 'InstagramKit'
  s.dependency 'SDWebImage'
end
