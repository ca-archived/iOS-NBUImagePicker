//
//  NBUImagePicker.h
//  NBUImagePicker
//
//  Created by Ernesto Rivera on 2012/07/11.
//  Copyright (c) 2012-2013 CyberAgent Inc.
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
#ifdef COCOAPODS_POD_AVAILABLE_NBULog
    #import "NBULog+NBUImagePicker.h"
#endif

/// Camera
#ifdef COCOAPODS_POD_AVAILABLE_NBUImagePicker_Camera
    #import "NBUCamera.h"
#endif

/// Assets
#ifdef COCOAPODS_POD_AVAILABLE_NBUImagePicker_Assets
    #import "NBUAssets.h"
#endif

/// Filters
#ifdef COCOAPODS_POD_AVAILABLE_NBUImagePicker_Filters
    #import "NBUFilters.h"
#endif

/// Gallery
#ifdef COCOAPODS_POD_AVAILABLE_NBUImagePicker_Gallery
    #import "NBUGallery.h"
#endif

/// Image Editing
#ifdef COCOAPODS_POD_AVAILABLE_NBUImagePicker_Image
    #import "NBUCropView.h"
    #import "NBUEditImageViewController.h"
    #import "NBUEditMultiImageViewController.h"
#endif

/// Media Info
#ifdef COCOAPODS_POD_AVAILABLE_NBUImagePicker_MediaInfo
    #import "NBUMediaInfo.h"
#endif

/// Image Picker
#ifdef COCOAPODS_POD_AVAILABLE_NBUImagePicker_Picker
    #import "NBUImagePickerController.h"
#endif

/**
 NBUImagePicker static library.
 */
@interface NBUImagePicker : NSObject

/// The current NBUImagePicker library version.
+ (NSString *)version;

/// The NBUImagePickerResources NSBundle.
+ (NSBundle *)bundle;

@end

