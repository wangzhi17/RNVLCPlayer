Pod::Spec.new do |s|
  s.name         = "RNVLCPlayer"
  s.version      = "1.0.0"
  s.summary      = "VLC player"
  s.requires_arc = true
  s.author       = { 'wangzhi17' => 'wangzhi0114@163.com' }
  s.license      = 'MIT'
  s.homepage     = 'https://github.com/wangzhi17/RNVLCPlayer.git'
  s.source       = { :git => "https://github.com/wangzhi17/RNVLCPlayer.git" }
  s.source_files = 'ios/RNVLCPlayer/*'
  s.platform     = :ios, "8.0"
  s.static_framework = true
  s.dependency 'React'
  s.dependency 'MobileVLCKit', '3.3.17'
end
