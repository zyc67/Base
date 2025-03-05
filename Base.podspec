#
# Be sure to run `pod lib lint Base.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Base'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Base.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'this is a swift base component library'

  s.homepage         = 'https://github.com/zyc67/Base'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zyc67' => 'chao790784459@126.com' }
  s.source           = { :git => 'https://github.com/zyc67/Base.git.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'


  s.subspec 'Extension' do |ss|
        ss.source_files = 'Base/Classes/Extension/**/*'
        ss.dependency 'DeviceKit'
    end
    s.subspec 'Base' do |ss|
        ss.source_files = 'Base/Classes/Base/**/*'
        ss.dependency 'Base/Extension'
        ss.dependency 'Moya'
        ss.dependency 'SwiftyJSON'
        ss.dependency 'SnapKit'
    end
    s.subspec 'Refresh' do |ss|
        ss.source_files = 'Base/Classes/Refresh/**/*.swift'
        ss.dependency 'Base/Extension'
        ss.resource_bundles = {
            'Refresh' => ['Base/Assets/*.png']
        }
    end

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'DeviceKit'
  s.dependency 'Moya'
  s.dependency 'SwiftyJSON'
  s.dependency 'SnapKit'
end
