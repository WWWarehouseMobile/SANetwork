Pod::Spec.new do |s|
  s.name         = "SANetwork"
  s.version      = "1.0.2"
  s.summary      = "离散式请求，对AFNetworking的二次封装"
  s.license      = 'MIT'
  s.author       = { "学宝" => "zhanxuebao@outlook.com" }
  s.homepage     = "https://github.com/ISCSMobileOrg/SANetwork"
  s.platform     = :ios,'7.0'
  s.ios.deployment_target = '7.0'
  s.source       = { :git => "https://github.com/ISCSMobileOrg/SANetwork.git", :tag => s.version.to_s, :submodules => true}
  s.requires_arc = true
  s.public_header_files = 'SANetwork/SANetwork.h'
  s.source_files = 'SANetwork/*.{h,m}'
  s.dependency 'AFNetworking', '~> 3.0'
end
