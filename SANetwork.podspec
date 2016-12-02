Pod::Spec.new do |s|
  s.name         = "SANetwork"
  s.version      = "1.0.0"
  s.summary      = "离散式请求，对AFNetworking的二次封装"
  s.license      = 'MIT'
  s.author       = { "阿宝" => "zhanxuebao@outlook.com" }
  s.homepage     = "https://github.com/ISCSMobileOrg/SANetwork"
  s.platform     = :ios,'7.0'
  s.ios.deployment_target = '7.0'
  s.source       = { :git => "https://github.com/ISCSMobileOrg/SANetwork.git", :tag => s.version.to_s, :submodules => true}
  s.requires_arc = true
  s.public_header_files = 'SANetwork/SANetwork.h'
  s.source_files = 'SANetwork/SANetwork.h'

  s.subspec 'SANetworkLogger' do |ss|
    ss.source_files = 'SANetwork/SANetworkLogger/*.{h,m}'
  end

  s.subspec 'SANetworkProtocol' do |ss|
    ss.source_files = 'SANetwork/SANetworkProtocol/*.{h,m}'
  end

  s.subspec 'SANetwork' do |ss|
    ss.source_files = 'SANetwork/SANetwork/*.{h,m}'
    ss.dependency 'SANetwork/SANetworkProtocol'
    ss.dependency 'SANetwork/SANetworkLogger'
  end

  s.subspec 'SANetworkAccessory' do |ss|
    ss.source_files = 'SANetwork/SANetworkAccessory/*.{h,m}'
    ss.dependency 'SANetwork/SANetworkProtocol'
    ss.dependency 'MBProgressHUD', '~> 0.9.2'
    ss.dependency 'MJRefresh', '~> 3.1.0'
  end

  s.dependency 'PINCache', '~> 2.2.2'
  s.dependency 'AFNetworking', '~> 3.0'

end
