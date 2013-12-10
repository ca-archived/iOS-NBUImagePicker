

Pod::Spec.new do |s|
    
    s.name          = "NBUImagePicker"
    s.version       = "1.0.0"
    s.summary       = "Localizable image picker with fully customizable AVFondation camera, assets, cropping and filters."
    s.homepage      = "http://cyberagent.github.io/iOS-NBUImagePicker/"
    s.license       = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.author        = { "CyberAgent Inc." => "", "Ernesto Rivera" => "rivera_ernesto@cyberagent.co.jp" }
    s.source        = { :git => "https://github.com/CyberAgent/iOS-NBUImagePicker.git", :tag => "#{s.version}" }
    s.screenshots   = [ "" ]
    
    s.platform      = :ios, '5.0'
    s.requires_arc  = true
    s.source_files  = 'Source/**/*.{h,m}'
    s.preserve_paths = "README.md", "NOTICE"
    s.resource_bundle = { 'NBUImagePicker' => ['Resources/*.{png,lproj}', 'Resources/filters', 'Source/**/*.{xib}'] }
    
    s.dependency 'NBUKit',      '>= 2.0.0'
    s.dependency 'GPUImage',    '>= 0.1.2'
    s.dependency 'RBVolumeButtons'
    
    s.frameworks = 'AVFoundation', 'AssetsLibrary', 'CoreImage'
    
end

