//
//  NBUAssetsGroupViewController.m
//  NBUImagePicker
//
//  Created by Ernesto Rivera on 2012/08/01.
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

#import "NBUAssetsGroupViewController.h"
#import "NBUImagePickerPrivate.h"
#import <AssetsLibrary/AssetsLibrary.h>

// Class extension
@interface NBUAssetsGroupViewController () <ObjectArrayViewDelegate>

@end


@implementation NBUAssetsGroupViewController
{
    NSMutableArray * _selectedAssets;
}

@dynamic assetsGroup;
@synthesize selectedAssetsURLs = _selectedAssetsURLs;

// TODO: Remove
- (void)setScrollOffset
{
    // *** Do nothing, just to avoit ScrollViewController from resetting the contentOffset ***
}

- (void)commonInit
{
    [super commonInit];
    
    _loadSize = 100;
    _selectedAssets = [NSMutableArray array];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Customization
    self.scrollView.alwaysBounceVertical = YES;
    
    // Configure grid view
    CGFloat margin = 4.0;
    NSUInteger numberOfThumbsPerRow = floorf((_gridView.size.width - margin) / (75.0 + margin));
    CGFloat thumbSize = (_gridView.size.width - (numberOfThumbsPerRow + 1) * margin) / numberOfThumbsPerRow;
    _gridView.margin = CGSizeMake(margin, margin);
    _gridView.targetObjectViewSize = CGSizeMake(thumbSize, thumbSize);
    _gridView.nibNameForViews = @"NBUAssetThumbnailView";
    _gridView.equallySizedViews = YES;
    _gridView.animated = NO;
    _gridView.delegate = self;
    [_gridView startObservingScrollViewDidScroll];
}

- (void)objectUpdated:(NSDictionary *)userInfo
{
    [super objectUpdated:userInfo];
    
    // Clean up before reuse
    NBUAssetsGroup * oldGroup = userInfo[NBUObjectUpdatedOldObjectKey];
    if (oldGroup)
    {
        [oldGroup stopLoadingAssets];
        [_gridView resetGridView];
    }
    
    // Set the group name
    if (_groupNameLabel)
        _groupNameLabel.text = self.assetsGroup.name;
    else
        self.title = self.assetsGroup.name;
    self.selectedAssets = nil;
    
    // Check the number of images
    [self.assetsGroup stopLoadingAssets];
    NSUInteger totalCount = self.assetsGroup.imageAssetsCount;
    
    // And update the count label
    if (_assetsCountLabel)
    {
        switch (totalCount)
        {
            case 0:
            {
                _assetsCountLabel.text = [NSString stringWithFormat:NBULocalizedString(@"NBUAssetsGroupViewController NoImagesLabel", @"No images"),
                                          totalCount];
                break;
            }
            case 1:
            {
                _assetsCountLabel.text = [NSString stringWithFormat:NBULocalizedString(@"NBUAssetsGroupView Only one image", @"1 image"),
                                          totalCount];
                break;
            }
            default:
            {
                _assetsCountLabel.text = [NSString stringWithFormat:NBULocalizedString(@"NBUAssetsGroupView Number of images", @"%d images"),
                                          totalCount];
                break;
            }
        }
    }
    
    // No need to load assets
    if (totalCount == 0)
    {
        self.loading = NO;
        return;
    }
    
    // Load assets
    NBULogInfo(@"Loading %@ images for group %@...", @(totalCount), self.assetsGroup.name);
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       self.loading = YES;
                   });
    __weak NBUAssetsGroupViewController * weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        [weakSelf.assetsGroup assetsWithTypes:NBUAssetTypeImage
                                    atIndexes:nil
                                 reverseOrder:_reverseOrder
                          incrementalLoadSize:_loadSize
                                  resultBlock:^(NSArray * assets,
                                                BOOL finished,
                                                NSError * error)
         {
             if (!error)
             {
                 _assets = assets;
                 
                 // Update from time to time only...
                 if (finished ||
                     (assets.count == _loadSize) ||
                     (assets.count == _loadSize * 4))
                 {
                     NBULogDebug(@"...%@ images loaded", @(assets.count));
                     
                     // Finished?
                     if (finished)
                     {
                         NBULogInfo(@"Finished loading %@ images", @(assets.count));
                         
                         dispatch_async(dispatch_get_main_queue(), ^
                                        {
                                            weakSelf.loading = NO;
                                        });
                     }
                     
                     // Check for selectedAssets
                     NSArray * selectedAssets = [self selectedAssetsFromAssets:assets
                                                            selectedAssetsURLs:_selectedAssetsURLs];
                     
                     // Update grid view and selected assets on main thread
                     dispatch_async(dispatch_get_main_queue(), ^
                                    {
                                        self.selectedAssets = selectedAssets;
                                        weakSelf.gridView.objectArray = assets;
                                    });
                 }
             }
         }];
    });
    
}

- (void)setContinueButton:(id<UIButton>)continueButton
{
    _continueButton = continueButton;
    
    // Update the continue button
    _continueButton.enabled = _selectedAssets.count > 0;
}

- (void)setLoading:(BOOL)loading
{
    _loading = loading; // Enables KVO
	
    // Update label
	if (_loading)
	{
        [_gridView setNoContentsViewText:NBULocalizedString(@"NBUAssetsGroupViewController LoadingLabel", @"Loading images...")];
	}
	else
	{
		[_gridView setNoContentsViewText:NBULocalizedString(@"NBUAssetsGroupViewController NoImagesLabel", @"No images")];
	}
}

#pragma mark - Grid view delegate

- (void)objectArrayView:(ObjectArrayView *)arrayView
          configureView:(NBUAssetThumbnailView *)recycledView
             withObject:(NBUAsset *)asset
{
    recycledView.object = asset;
    recycledView.selected = [_selectedAssets containsObject:asset];
}

#pragma mark - Programatically managing selection

- (NSArray *)selectedAssets
{
    return [NSArray arrayWithArray:_selectedAssets];
}

- (void)setSelectedAssets:(NSArray *)selectedAssets
{
    _selectedAssets = [NSMutableArray arrayWithArray:selectedAssets];
    
    // Discard assets beyond the selection count limit
    if ((_selectionCountLimit > 0) &&
        (_selectedAssets.count > _selectionCountLimit))
    {
        [_selectedAssets removeObjectsInRange:NSMakeRange(_selectionCountLimit,
                                                          _selectedAssets.count - _selectionCountLimit)];
    }
    
    // Update the continue button
    _continueButton.enabled = _selectedAssets.count > 0;
    
    // Update current visible views
    for (NBUAssetThumbnailView * view in _gridView.currentViews)
    {
        view.selected = [selectedAssets containsObject:view.asset];
    }
    
    // Call the selection changed block
    if (_selectionChangedBlock) _selectionChangedBlock(self.selectedAssets);
}

- (NSArray *)selectedAssetsFromAssets:(NSArray *)assets
                   selectedAssetsURLs:(NSArray *)selectedAssetsURLs
{
    NSMutableArray * selectedAssets;
    if (selectedAssetsURLs.count > 0)
    {
        selectedAssets = [NSMutableArray array];
        for (NBUAsset * asset in assets)
        {
            for (NSURL * url in selectedAssetsURLs)
            {
                if ([asset.URL.absoluteString isEqualToString:url.absoluteString])
                {
                    [selectedAssets addObject:asset];
                    break;
                }
            }
            // Stop looking if we found all of them
            if (selectedAssets.count == selectedAssetsURLs.count)
                break;
        }
    }
    return selectedAssets;
}

- (void)setSelectedAssetsURLs:(NSArray *)selectedAssetsURLs
{
    _selectedAssetsURLs = selectedAssetsURLs;
    
    self.selectedAssets = [self selectedAssetsFromAssets:self.assets
                                      selectedAssetsURLs:selectedAssetsURLs];
}

- (NSArray *)selectedAssetsURLs
{
    if (!self.isViewLoaded)
        return _selectedAssetsURLs;
    
    // Make sure that we have the latest URLs by recreating them from the actual selectedAssets
    NSMutableArray * selectedAssetsURLs = [NSMutableArray array];
    for (NBUAsset * asset in _selectedAssets)
    {
        [selectedAssetsURLs addObject:asset.URL];
    }
    _selectedAssetsURLs = selectedAssetsURLs;
    return selectedAssetsURLs;
}

#pragma mark - Manage taps

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(thumbnailViewSelectionStateChanged:)
                                                 name:NBUAssetThumbnailViewSelectionStateChangedNotification
                                               object:nil];
    
    // Clear selection if in single selection mode
    if (_clearsSelectionOnViewWillAppear)
    {
        self.selectedAssets = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NBUAssetThumbnailViewSelectionStateChangedNotification
                                                  object:nil];
}

- (void)thumbnailViewSelectionStateChanged:(NSNotification *)notification
{
    // Refresh selected assets
    NBUAssetThumbnailView * assetView = (NBUAssetThumbnailView *)notification.object;
    
    // Selected
    if (assetView.selected)
    {
        // Prevent further selections?
        if ((_selectionCountLimit > 0) &&
            (_selectedAssets.count >= _selectionCountLimit))
        {
            assetView.selected = NO;
            return;
        }
        
        NBULogVerbose(@"Asset %p selected", assetView.asset);
        [_selectedAssets addObject:assetView.asset];
    }
    
    // Deselected
    else
    {
        NBULogVerbose(@"Asset %p deselected", assetView.asset);
        [_selectedAssets removeObject:assetView.asset];
    }
    
    // Update the continue button
    _continueButton.enabled = _selectedAssets.count > 0;
    
    // Call the selection changed block
    if (_selectionChangedBlock) _selectionChangedBlock(self.selectedAssets);
}

@end

