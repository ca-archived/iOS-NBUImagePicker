//
//  NBUImagePicker.h
//  NBUImagePicker
//
//  Created by Ernesto Rivera on 2012/07/11.
//  Copyright (c) 2012-2014 CyberAgent Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

/// NBULog
#if __has_include("NBULog.h")
    #import "NBULog+NBUImagePicker.h"
#endif

/// Camera
#if __has_include("NBUCamera.h")
    #import "NBUCamera.h"
#endif

/// Assets
#if __has_include("NBUAssets.h")
    #import "NBUAssets.h"
#endif

/// Filters
#if __has_include("NBUFilters.h")
    #import "NBUFilters.h"
#endif

/// Gallery
#if __has_include("NBUGallery.h")
    #import "NBUGallery.h"
#endif

/// Image Editing
#if __has_include("NBUCropView.h")
    #import "NBUCropView.h"
    #import "NBUEditImageViewController.h"
    #import "NBUEditMultiImageViewController.h"
#endif

/// Media Info
#if __has_include("NBUMediaInfo.h")
    #import "NBUMediaInfo.h"
#endif

/// Image Picker
#if __has_include("NBUImagePickerController.h")
    #import "NBUImagePickerController.h"
#endif

/**
 NBUImagePicker static library.
 */
@interface NBUImagePicker : NSObject

/// The NBUImagePickerResources NSBundle.
+ (NSBundle *)bundle;

/// The NBUImagePicker Storyboard.
+ (UIStoryboard *)mainStoryboard;

@end

