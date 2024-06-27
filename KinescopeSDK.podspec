Pod::Spec.new do |s|
  s.name = "KinescopeSDK"
  s.version = "0.2.2"
  s.summary = "Library to help you include Kinescope player into your mobile iOS application"
  s.homepage = "https://github.com/kinescope/ios-kinescope-player"
  s.license = "MIT"
  s.author = { "Surf Studio" => "surfstudio36@gmail.com"  }
  s.source = { :git => "https://github.com/kinescope/ios-kinescope-player.git", :tag => s.version }

  s.source_files = 'Sources/KinescopeSDK/**/*.swift'
  s.framework = 'UIKit'
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'

  s.dependency 'SwiftProtobuf', '1.26.0'
  s.dependency 'M3U8Kit', '~> 1.0'

  s.resource_bundles = { 'KinescopeSDK' => ['Sources/KinescopeSDK/Resources/*.xcassets', 'Sources/KinescopeSDK/Resources/*.lproj/*.strings'] }
end
