#
# Be sure to run `pod lib lint SANetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SANetwork'
  s.version          = '1.2.0'
  s.summary          = '离散式网络库'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/WWWarehouseMobile/SANetwork'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '学宝' => 'zhanxuebao@outlook.com' }
  s.source           = { :git => 'https://github.com/WWWarehouseMobile/SANetwork.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'SANetwork/Classes/**/*'
  #s.public_header_files = 'SANetwork/Classes/**/*.h'

  s.dependency 'AFNetworking', '~> 4.0'
end
