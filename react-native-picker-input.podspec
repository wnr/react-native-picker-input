require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = package['name']
  s.version      = package['version']
  s.summary      = package['name']
  s.description  = package['description']
  s.homepage     = package['homepage']
  s.license      = package['license']
  s.author       = { "author" => "lucas@wiener.se" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/wnr/react-native-picker-input.git", :tag => "1.0.0" }
  s.source_files = "ios/**/*.{h,m}"
  s.requires_arc = true
  s.dependency "React"
  #s.dependency "others"

end
