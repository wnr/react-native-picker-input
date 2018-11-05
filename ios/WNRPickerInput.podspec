
Pod::Spec.new do |s|
  s.name         = "react-native-picker-input"
  s.version      = "1.0.0"
  s.summary      = "react-native-picker-input"
  s.description  = <<-DESC
                  react-native-picker-input
                   DESC
  s.homepage     = ""
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "author" => "lucas@wiener.se" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/wnr/react-native-picker-input.git", :tag => "master" }
  s.source_files  = "react-native-picker-input/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  