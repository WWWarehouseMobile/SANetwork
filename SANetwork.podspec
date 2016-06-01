Pod::Spec.new do |s|
  s.name         = "SANetwork"
  s.version      = "0.0.5"
  s.summary      = "离散式请求二次封装"
  s.license      = 'MIT'
  s.author       = { "阿宝" => "zhanxuebao@outlook.com" }
  s.homepage     = "https://github.com/ISCS-iOS/SANetwork"
  s.platform     = :ios,'7.0'
  s.ios.deployment_target = '7.0'
  s.source       = { :git => "https://github.com/ISCS-iOS/SANetwork.git", :tag => s.version.to_s}
  s.requires_arc = true
  s.public_header_files = 'SANetwork/SANetwork.h'
  s.source_files = 'SANetwork/*.{h,m}'

  s.subspec 'SANetworkLogger' do |ss|
    ss.source_files = 'SANetwork/SALogger/*.{h,m}'
  end

  s.subspec 'SANetworkProtocol' do |ss|
    ss.source_files = 'SANetwork/SANetworkProtocol/*.{h,m}'
  end

  s.subspec "SANetworkAccessory" do |ss|
    ss.source_files = "SANetwork/SANetworkAccessory/*.{h,m}"
    ss.dependency 'SANetwork/SANetworkProtocol'
    ss.dependency 'MBProgressHUD', '~> 0.9.2'
    ss.dependency 'MJRefresh', '~> 3.1.0'
  end

    s.dependency 'PINCache', '~> 2.2.2'
    s.dependency 'AFNetworking', '~> 3.0'
    s.dependency 'RealReachability', '~> 1.1.2'
    s.dependency 'YYModel','~> 1.0.2'
end
