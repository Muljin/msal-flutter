#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'msal_flutter'
  s.version          = '1.0.2'
  s.summary          = 'MSAL Flutter Wrapper'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://www.muljin.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Muljin Pte. Ltd.' => 'info@muljin.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'MSAL', '~> 1.2.0'
  s.swift_version = '5.0'
  s.ios.deployment_target = '11.0'
end

