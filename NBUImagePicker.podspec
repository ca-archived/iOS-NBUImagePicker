

Pod::Spec.new do |s|
    
    s.name          = "NBUImagePicker"
    s.version       = "1.0.0"
    s.summary       = "Modular image picker with AVFondation, simulator-compatible camera, assets browser, filters and more."
    s.description   = "Modular and fully customizable UIImagePickerController replacement with AVFondation, simulator-compatible camera, AssertsLibrary and custom directory assets' browser, cropping, filters and gallery."
    s.homepage      = "http://cyberagent.github.io/iOS-NBUImagePicker/"
    s.license       = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.author        = { "CyberAgent Inc." => "", "Ernesto Rivera" => "rivera_ernesto@cyberagent.co.jp" }
    s.source        = { :git => "https://github.com/CyberAgent/iOS-NBUImagePicker.git", :tag => "#{s.version}" }
    s.screenshots   = [ "" ]
    
    s.platform      = :ios, '5.0'
    s.requires_arc  = true
    s.source_files  = 'Source/*.{h,m}'
    s.preserve_paths = "README.md", "NOTICE"
    
    s.dependency 'NBUKit',      '>= 2.0.0'
    
    s.subspec 'Camera' do |sub|
        sub.source_files    = 'Source/Camera/*.{h,m}'
        sub.frameworks      = 'AVFoundation'
        sub.dependency      'RBVolumeButtons'
    end
    
    s.subspec 'Assets' do |sub|
        sub.source_files    = 'Source/Assets/*.{h,m}'
        sub.frameworks      = 'AssetsLibrary'
    end
    
    s.subspec 'Filters' do |sub|
        sub.source_files    = 'Source/Filters/*.{h,m}'
        sub.dependency      'GPUImage', '>= 0.1.2'
    end
    
    s.subspec 'Image' do |sub|
        sub.source_files    = 'Source/Image/*.{h,m}'
    end
    
    s.subspec 'Gallery' do |sub|
        sub.source_files    = 'Source/Gallery/*.{h,m}'
    end
    
    s.subspec 'MediaInfo' do |sub|
        sub.source_files    = 'Source/MediaInfo/*.{h,m}'
    end
    
    s.subspec 'Picker' do |sub|
        sub.source_files    = 'Source/Picker/*.{h,m}'
    end
    
    s.subspec 'Resources' do |sub|
        sub.resource_bundle = { 'NBUImagePicker' => ['Resources/*.{png,lproj}', 'Resources/filters', 'Source/**/*.{xib}'] }
    end
    
end

