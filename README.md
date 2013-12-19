
NBUImagePicker
==============

Modular and fully customizable UIImagePickerController replacement with AVFondation, simulator-compatible camera, AssertsLibrary and custom directory assets' browser, cropping, filters and gallery.

_Uses [NBUCore](https://github.com/CyberAgent/iOS-NBUCore) and [NBUKit](https://github.com/CyberAgent/iOS-NBUKit), supports [NBULog](https://github.com/CyberAgent/iOS-NBULog)._

## Features

### NBUCameraView

Customizable AVFoundation-based camera view.

Can be embeded in any superview, custom UIViewController or used along NBUCameraViewController and even takes
mock pictures on the iOS simulator!

![NBUCamera](https://raw.github.com/wiki/CyberAgent/iOS-NBUKit/Camera1.png)
![NBUCamera](https://raw.github.com/wiki/CyberAgent/iOS-NBUKit/Camera2.png)

### NBUAssets

Multiple classes of all three MVC categories to ease access to AssetsLibrary listening to
change notifications to stay always in valid.

Also support for _local assets_: Images in folders that are handled just like regular library assets.

![NBUAssets](https://raw.github.com/wiki/CyberAgent/iOS-NBUKit/Assets1.png)
![NBUAssets](https://raw.github.com/wiki/CyberAgent/iOS-NBUKit/Assets2.png)

### Cropping/Filters

Customizable views and controllers to modify images (filters and cropping).

Filters from CoreImage and [GPUImage](https://github.com/BradLarson/GPUImage) but could be extended to
other libraries as well.

![NBUEdit](https://raw.github.com/wiki/CyberAgent/iOS-NBUKit/Edit2.png)
![NBUEdit](https://raw.github.com/wiki/CyberAgent/iOS-NBUKit/Edit3.png)

### NBUGallery

Image slideshow in development inspired by [FGallery](https://github.com/gdavis/FGallery-iPhone).

![NBUGallery](https://raw.github.com/wiki/CyberAgent/iOS-NBUKit/Gallery1.png)

### NBUImagePickerController

Block-based image picker that combines all modules mentioned above.

![NBUPicker](https://raw.github.com/wiki/CyberAgent/iOS-NBUKit/Picker1.png)

## Customization

The main goal of NBUImagePicker is to be fully [customizable](https://github.com/CyberAgent/iOS-NBUKit/wiki/NBUKit-Customization) and easy to extend.

## Installation

Add the following to your [CocoaPods](http://cocoapods.org)' [Podfile](http://docs.cocoapods.org/podfile.html):

```ruby
platform :ios, '5.0'

# Pre-release versions
pod 'NBUImagePicker', :git => 'https://github.com/CyberAgent/iOS-NBUImagePicker.git', :commit => 'xxx'
pod 'NBUKit', :git => 'https://github.com/CyberAgent/iOS-NBUKit.git', :commit => 'xxx'

# Optional for dynamic logging
pod 'NBULog'

# Optional for on-device log console
pod 'LumberjackConsole'
```

Or manually chose the only components you need:

```ruby
pod 'NBUImagePicker/Camera'  # AVFoundation-based camera
pod 'NBUImagePicker/Assets'  # AssetsLibrary and custom path asset selection
pod 'NBUImagePicker/Filters' # CoreImage and GPUImage filters' wrapping
pod 'NBUImagePicker/Gallery' # Image preview
pod 'NBUImagePicker/Picker'  # Combinations of the modules above
```

##License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.


