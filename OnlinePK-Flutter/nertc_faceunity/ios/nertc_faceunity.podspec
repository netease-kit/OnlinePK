#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint beauty.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'nertc_faceunity'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin.'
  s.description      = <<-DESC
A new Flutter plugin.
                       DESC
  s.homepage         = 'https://yunxin.163.com/'
  s.license          = { :file => '../LICENSE' }
  s.author           ={ 'NetEase, Inc.' => 'liuqijun@corp.netease.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  s.dependency 'Nama-lite', '8.5.0'
  s.dependency 'NERtcSDK/RtcBasic', '>=5.4.0'
  # s.static_framework = true
#  arr = Array.new
#  arr.push('./**/nertc.framework')
#  s.ios.vendored_frameworks = arr

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES',
    'ENABLE_BITCODE' => 'NO', 'VALID_ARCHS' => 'arm64 armv7', 'ONLY_ACTIVE_ARCH' => 'YES' }
end
