#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'easy_audience_network'
  s.version          = '0.0.6'
  s.summary          = 'Facebook Audience Network plugin for Flutter application'
  s.description      = <<-DESC
Facebook Audience Network plugin for Flutter application
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Cross Code' => 'admin@crosscode.dev' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'FBAudienceNetwork', '~> 6.12.0'

  s.static_framework = true
  s.swift_version = '4.0'
  s.ios.deployment_target = '9.0'
end

