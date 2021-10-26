Pod::Spec.new do |s|

  s.name             = "LibraryTemplate"
  s.version          = "0.1.0"
  s.summary          = "Template for creating a new iOS library"
  s.description      = "Template for creating a new iOS library."
  s.homepage         = "TODO"
  s.author           = { "TODO" => "TODO" }
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.source           = { :git => "https://github.com/hkellaway/ios-library-template.git", :tag => s.version.to_s }
  
  s.platforms        = { :ios => "8.0" }
  s.requires_arc     = true

  s.source_files     = 'Sources/LibraryTemplate/*.{swift}'

end
