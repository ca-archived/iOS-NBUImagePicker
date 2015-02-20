//
//  LibraryViewController.m
//  PickerDemo
//
//  Created by Ernesto Rivera on 2012/11/09.
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

#import "LibraryViewController.h"
#import "AssetsGroupViewController.h"

@implementation LibraryViewController

+(void)initialize
{
    if (self == [LibraryViewController class])
    {
        // Register our custom directory albums
        [[NBUAssetsLibrary sharedLibrary] registerDirectoryGroupforURL:[UIApplication sharedApplication].documentsDirectory
                                                                  name:@"App's Documents directory"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure grid view
    self.objectTableView.nibNameForViews = @"CustomAssetsGroupView";
    
    // Customization
    self.customBackButtonTitle = @"Albums";
    self.assetsGroupController = [self.storyboard instantiateViewControllerWithIdentifier:@"assetsGroupController"];
}

#pragma mark - Handling access authorization

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Authorized?
    if (![NBUAssetsLibrary sharedLibrary].userDeniedAccess)
    {
        // No need for info button
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)accessInfo:(id)sender
{
    // User denied access?
    if ([NBUAssetsLibrary sharedLibrary].userDeniedAccess)
    {
        [[[UIAlertView alloc] initWithTitle:@"Access denied"
                                    message:@"Please go to Settings:Privacy:Photos to enable library access" delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    
    // Parental controls
    if ([NBUAssetsLibrary sharedLibrary].restrictedAccess)
    {
        [[[UIAlertView alloc] initWithTitle:@"Parental restrictions"
                                    message:@"Please go to Settings:General:Restrictions to enable library access" delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

@end

