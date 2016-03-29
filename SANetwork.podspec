Pod::Spec.new do |s|
  s.name         = "SANetwork"
  s.version      = "0.0.3"
  s.summary      = "离散式请求二次封装"
  s.license      = 'MIT'
  s.author       = { "阿宝" => "zhanxuebao@outlook.com" }
  s.homepage     = "https://github.com/ISCS-iOS/SANetwork"
  s.platform     = :ios,'7.0'
  s.ios.deployment_target = '7.0'
  s.source       = { :git => "https://github.com/ISCS-iOS/SANetwork.git", :tag => s.version.to_s}
  s.requires_arc = true
  s.public_header_files = 'SANetworkClass/SANetwork.h'
  s.source_files = 'SANetworkClass/SANetwork.h'
  s.subspec 'SANetworkProtocol' do |ss|
    ss.source_files = 'SANetworkClass/SANetworkProtocol/*.{h,m}'
  end
  s.subspec "SANetworkAccessory" do |ss|
    ss.source_files = "SANetworkClass/SANetworkAccessory/*.{h,m}"
    ss.dependency 'SANetwork/SANetworkProtocol'
    ss.dependency 'MBProgressHUD', '~> 0.9.2'
    ss.dependency 'MJRefresh', '~> 3.1.0'
  end
  s.subspec "SANetwork" do |ss|
    ss.source_files = "SANetworkClass/SANetwork/*.{h,m}"
    ss.dependency 'SANetwork/SANetworkProtocol'
    ss.dependency 'PINCache', '~> 2.2.2'
    ss.dependency 'AFNetworking', '~> 3.0'
    ss.dependency 'RealReachability', '~> 1.1.2'
  end
end
