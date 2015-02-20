//
//  NBUEditImageViewController.m
//  NBUImagePicker
//
//  Created by Ernesto Rivera on 2012/11/30.
//  Copyright (c) 2012-2015 CyberAgent Inc.
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

#import "NBUEditImageViewController.h"
#import "NBUImagePickerPrivate.h"

@implementation NBUEditImageViewController

@dynamic image;
@synthesize mediaInfo = _mediaInfo;
@synthesize filters = _filters;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    #if __has_include("NBUFilters.h")
    // Configure filterView
    if (!_filterView)
    {
        NBULogVerbose(@"Filters disabled");
    }
    else
    {
        _filterView.filters = self.filters;
        _filterView.workingSize = _workingSize;
    }
    #endif
    
    // Configure cropView
    if (!_cropView)
    {
        NBULogVerbose(@"Crop disabled");
    }
    else
    {
        if (_maximumScaleFactor == 0.0)
        {
            _maximumScaleFactor = 1.5;
        }
        if (CGSizeEqualToSize(_cropGuideSize, CGSizeZero))
        {
            CGFloat cropGuide = MIN(self.view.bounds.size.width, self.view.bounds.size.height);
            _cropGuideSize = CGSizeMake(cropGuide - 20.0, cropGuide - 20.0);
        }
        _cropView.cropGuideSize = _cropGuideSize;
        _cropView.maximumScaleFactor = _maximumScaleFactor;
    }
}

#if __has_include("NBUFilters.h")
- (void)setFilters:(NSArray *)filters
{
    _filters = filters;
    
    _filterView.filters = filters;
}

- (NSArray *)filters
{
    if (!_filters)
    {
        // Set some default filters
        _filters = @[
                     [NBUFilterProvider filterWithName:nil
                                                  type:NBUFilterTypeNone
                                                values:nil],
                     [NBUFilterProvider filterWithName:nil
                                                  type:NBUFilterTypeGamma
                                                values:nil],
                     [NBUFilterProvider filterWithName:nil
                                                  type:NBUFilterTypeSaturation
                                                values:nil],
                     [NBUFilterProvider filterWithName:nil
                                                  type:NBUFilterTypeAuto
                                                values:nil]
                     ];
        
        NBULogInfo(@"Initialized with filters: %@", _filters);
    }
    return _filters;
}
#endif

- (void)objectUpdated:(NSDictionary *)userInfo
{
    [super objectUpdated:userInfo];
    
    // Start with cropView if present
    if (_cropView)
    {
        _cropView.image = self.image;
    }
    
    #if __has_include("NBUFilters.h")
    // Or just filterView
    else
    {
        _filterView.image = self.image;
    }
    #endif
}

- (UIImage *)editedImage
{
    NBULogVerbose(@"Processing image...");
    
    // Get the resulting image from cropView if present
    UIImage * image;
    if (_cropView)
    {
        image = _cropView.image;
    }
    
    #if __has_include("NBUFilters.h")
    // Or from filterView
    else
    {
        image = _filterView.image;
    }
    #endif
    
    // Set to target size?
    if (!CGSizeEqualToSize(_cropTargetSize, CGSizeZero))
    {
        image = [image imageDonwsizedToFill:_cropTargetSize];
    }
    
    NBULogInfo(@"Processed image with size: %@", NSStringFromCGSize(image.size));
    
    return image;
}

- (void)setMediaInfo:(NBUMediaInfo *)mediaInfo
{
    NBULogInfo(@"%@ %@", THIS_METHOD, mediaInfo);
    
    _mediaInfo = mediaInfo;
    
    self.object = mediaInfo.originalImage;
    
    #if __has_include("NBUFilters.h")
    // Restore state
    NBUFilter * filter = mediaInfo.attributes[NBUMediaInfoFiltersKey];
    if (filter)
    {
        _filterView.currentFilter = filter;
    }
    #endif
}

- (NBUMediaInfo *)mediaInfo
{
    // Add metadata
    if (_cropView)
    {
        _mediaInfo.attributes[NBUMediaInfoCropRectKey] = [NSValue valueWithCGRect:_cropView.currentCropRect];
    }
    #if __has_include("NBUFilters.h")
    if (_filterView)
    {
        NBUFilter * currentFilter = _filterView.currentFilter;
        if (currentFilter)
            _mediaInfo.attributes[NBUMediaInfoFiltersKey] = currentFilter;
    }
    #endif
    
    return _mediaInfo;
}

- (NBUMediaInfo *)editedMediaInfo
{
    // Try to refresh the edited image
    UIImage * editedImage = self.editedImage;
    if (editedImage)
    {
        _mediaInfo.editedImage = editedImage;
    }
    
    return self.mediaInfo;
}

- (void)reset:(id)sender
{
    [self objectUpdated:nil];
}

- (void)apply:(id)sender
{
    if (_resultBlock)
    {
        #if __has_include("NBUFilters.h")
        _filterView.activityView.hidden = NO;
        #endif
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
        {
            UIImage * processedImage = self.editedImage;
            dispatch_async(dispatch_get_main_queue(), ^
            {
                #if __has_include("NBUFilters.h")
                _filterView.activityView.hidden = YES;
                #endif
                _resultBlock(processedImage);
            });
        });
    }
}

@end

