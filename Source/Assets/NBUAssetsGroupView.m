//
//  NBUAssetsGroupView.m
//  NBUImagePicker
//
//  Created by Ernesto Rivera on 2012/08/17.
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

#import "NBUAssetsGroupView.h"
#import "NBUImagePickerPrivate.h"
#import "NBUAssetsLibraryViewController.h"

static UIImage * _noContentsImage;

@implementation NBUAssetsGroupView

@dynamic assetsGroup;

- (void)commonInit
{
    [super commonInit];
    
    self.recognizeTap = YES;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Localization
    if ([_editableView isKindOfClass:[UILabel class]])
    {
        ((UILabel *)_editableView).text = NBULocalizedString(@"NBUAssetsGroupView Editable label", @"editable");
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _noContentsImage = _posterImageView.image;
    });
}

- (void)objectUpdated:(NSDictionary *)userInfo
{
    [super objectUpdated:userInfo];
    
    // Update UI
    _nameLabel.text = self.object.name;
    NSUInteger count = self.assetsGroup.imageAssetsCount;
    if (count == 1)
    {
        _countLabel.text = [NSString stringWithFormat:NBULocalizedString(@"NBUAssetsGroupView Only one image", @"1 image"),
                            count];
    }
    else
    {
        _countLabel.text = [NSString stringWithFormat:NBULocalizedString(@"NBUAssetsGroupView Number of images", @"%d images"),
                            count];
    }
    if (count == 0)
    {
        // Try to use a custom poster image for empty groups
        _posterImageView.image = _noContentsImage ? _noContentsImage : self.object.posterImage;
    }
    else
    {
        // Normal poster image for non-empty groups
        _posterImageView.image = self.object.posterImage;
    }
    _editableView.hidden = !self.object.editable;
}

- (void)tapped:(id)sender
{
    [super tapped:sender];
    
    // Directly notify controller
    id controller = self.viewController;
    if ([controller respondsToSelector:@selector(assetsGroupViewTapped:)])
    {
        [controller performSelector:@selector(assetsGroupViewTapped:)
                         withObject:self];
    }
}

@end

