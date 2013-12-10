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

/// NBULog Category
#ifdef COCOAPODS_POD_AVAILABLE_NBULog
    #import "NBULog+NBUImagePicker.h"
#endif

/// Assets
#import "NBUAsset.h"
#import "NBUAssetsGroup.h"
#import "NBUAssetsGroupView.h"
#import "NBUAssetsGroupViewController.h"
#import "NBUAssetsLibrary.h"
#import "NBUAssetsLibraryViewController.h"
#import "NBUAssetThumbnailView.h"
#import "NBUAssetView.h"

/// Camera
#import "NBUCameraView.h"
#import "NBUCameraView.h"
#import "NBUCameraViewController.h"

/// Image Editing
#import "NBUCropView.h"
#import "NBUCoreImageFilterProvider.h"
#import "NBUCoreImageFilterProvider.h"
#import "NBUEditImageViewController.h"
#import "NBUEditMultiImageViewController.h"
#import "NBUFilter.h"
#import "NBUFilter.h"
#import "NBUFilterGroup.h"
#import "NBUFilterProvider.h"
#import "NBUFilterProvider.h"
#import "NBUFilterThumbnailView.h"
#import "NBUGPUImageFilterProvider.h"
#import "NBUPresetFilterView.h"

/// Gallery
#import "NBUGalleryThumbnailView.h"
#import "NBUGalleryView.h"
#import "NBUGalleryViewController.h"
#import "NBUImageLoader.h"
#import "NBUImageLoader.h"

/// Media Info
#import "NBUMediaInfo.h"

/// Image Picker
#import "NBUImagePickerController.h"

/**
 NBUImagePicker static library.
 */
@interface NBUImagePicker : NSObject

/// The current NBUImagePicker library version.
+ (NSString *)version;

/// The NBUImagePickerResources NSBundle.
+ (NSBundle *)bundle;

@end

