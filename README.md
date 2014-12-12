
NBUImagePicker
==============

[![Platform: iOS](https://img.shields.io/cocoapods/p/NBUImagePicker.svg?style=flat)](http://cocoadocs.org/docsets/NBUImagePicker/)
[![Version: 1.5.2](https://img.shields.io/cocoapods/v/NBUImagePicker.svg?style=flat)](http://cocoadocs.org/docsets/NBUImagePicker/)
[![License: Apache 2.0](https://img.shields.io/cocoapods/l/NBUImagePicker.svg?style=flat)](http://cocoadocs.org/docsets/NBUImagePicker/)
[![Dependency Status](https://www.versioneye.com/objective-c/NBUImagePicker/badge.svg?style=flat)](https://www.versioneye.com/objective-c/NBUImagePicker)
[![Build Status](http://img.shields.io/travis/CyberAgent/iOS-NBUImagePicker/master.svg?style=flat)](https://travis-ci.org/CyberAgent/iOS-NBUImagePicker)

Modular and fully customizable UIImagePickerController replacement with Simulator-compatible AVFondation camera, AssetsLibrary and custom directory assets' browser, and image cropping, filters and gallery.

_Uses [NBUCore](https://github.com/CyberAgent/iOS-NBUCore) and [NBUKit](https://github.com/CyberAgent/iOS-NBUKit). Supports [NBULog](https://github.com/CyberAgent/NBULog)._

## Demo

A demo project is [included](Demo) in the repository.

## Features

### Image Picker

Block-based UIImagePickerController replacement with as many/few features as you [need](#installation).

![Screenshot 1](http://cyberagent.github.io/iOS-NBUImagePicker/images/screenshot1.png)

Enable/disable modules or use them [stand-alone](#stand-alone-modules).

### Camera

Customizable AVFoundation-based camera UIView.

Can be embeded into any superview, custom UIViewController or used along NBUCameraViewController.
It even takes mock pictures in the iOS Simulator!

![Screenshot 2](http://cyberagent.github.io/iOS-NBUImagePicker/images/screenshot2.png)　![Screenshot 3](http://cyberagent.github.io/iOS-NBUImagePicker/images/screenshot3.png)

### Assets

Multiple classes of all three MVC categories to simplify access to AssetsLibrary while observing its
change notifications to stay always in a valid state.

Also support for _local assets_: Images in custom directories that are displayed like regular Assets Library albums.

![Screenshot 4](http://cyberagent.github.io/iOS-NBUImagePicker/images/screenshot4.png)　![Screenshot 5](http://cyberagent.github.io/iOS-NBUImagePicker/images/screenshot5.png)

### Image Editing

Customizable views and controllers to modify filter and crop images.

![Screenshot 6](http://cyberagent.github.io/iOS-NBUImagePicker/images/screenshot6.png)

Uses filters from CoreImage and [GPUImage](https://github.com/BradLarson/GPUImage) and can be extended to
other libraries as well.

### Image Gallery

Image slideshow in development inspired by [FGallery](https://github.com/gdavis/FGallery-iPhone).

![Screenshot 7](http://cyberagent.github.io/iOS-NBUImagePicker/images/screenshot7.png)

## Customization

The main goal of NBUImagePicker is to be fully [customizable](https://github.com/CyberAgent/iOS-NBUKit/wiki/NBUKit-Customization) and easy to extend.

Change element's sizes, position, customize picker workflow, add/remove/rename filters, localize for other languages, use cropping features from [other](https://github.com/kishikawakatsumi/PEPhotoCropEditor) libraries, etc.

![Screenshot 9](http://cyberagent.github.io/iOS-NBUImagePicker/images/screenshot9.png)　![Screenshot 10](http://cyberagent.github.io/iOS-NBUImagePicker/images/screenshot10.png)

![Screenshot 8](http://cyberagent.github.io/iOS-NBUImagePicker/images/screenshot8.png)

## Installation

Add the following to your [CocoaPods](http://cocoapods.org)' [Podfile](http://guides.cocoapods.org/syntax/podfile.html):

```ruby
platform :ios, '5.0'

# Recommended to keep GPUImage up-to-date
pod 'GPUImage', :head

#pod 'NBUImagePicker'

# Optional for dynamic logging
pod 'NBULog'

# Optional for on-device log console
pod 'LumberjackConsole'
```

### Stand-Alone Modules

Manually specify only the components you need:

```ruby
pod 'NBUImagePicker/Camera'  # AVFoundation-based camera
pod 'NBUImagePicker/Assets'  # AssetsLibrary and custom path asset selection
pod 'NBUImagePicker/Filters' # CoreImage and GPUImage filters' wrapping
pod 'NBUImagePicker/Image'   # Croping
pod 'NBUImagePicker/Gallery' # Image preview
pod 'NBUImagePicker/Picker'  # Combinations of the modules above except for filters
```

## Documentation

http://cocoadocs.org/docsets/NBUImagePicker/

## License

    Copyright 2012-2014 CyberAgent Inc.
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License. 
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

