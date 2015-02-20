//
//  NBUImagePickerController.m
//  NBUImagePicker
//
//  Created by Ernesto Rivera on 2012/11/12.
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

#import "NBUImagePickerController.h"
#import "NBUImagePickerPrivate.h"

@implementation NBUImagePickerController
{
    UIStoryboard * _customStoryboard;
    BOOL _returnMediaInfoMode;
    NSMutableArray * _mediaInfos;
    NSMutableDictionary * _previousSelectedAssetPaths;
    NSArray * _controllersToToggleBack;
}

+ (id)instantiateViewControllerWithIdentifier:(NSString *)identifier
                             customStoryboard:(UIStoryboard *)customStoryboard
{
    NBULogDebug(@"%@ %@", THIS_METHOD, identifier);
    
    // Try custom storyboard first
    NBUImagePickerController * controller;
    if (customStoryboard)
    {
        @try
        {
            controller = [customStoryboard instantiateViewControllerWithIdentifier:identifier];
        }
        @catch (NSException *exception)
        {
            NBULogDebug(@"No controller with identifier '%@' in %@", identifier, customStoryboard);
        }
    }
    
    // Else load from default storyboard (except for the picker)
    if (!controller && ![identifier isEqualToString:@"imagePicker"])
    {
        controller = [NBUImagePicker.mainStoryboard instantiateViewControllerWithIdentifier:identifier];
    }
    
    return controller;
}

+ (instancetype)pickerWithOptions:(NBUImagePickerOptions)options
                 customStoryboard:(UIStoryboard *)customStoryboard
                      resultBlock:(NBUImagePickerResultBlock)resultBlock
{
    NBUImagePickerController * controller = [self instantiateViewControllerWithIdentifier:@"imagePicker"
                                                                         customStoryboard:customStoryboard];
    
    // Load programatically?
    if (!controller)
    {
        controller = [self new];
    }
    
    // Configure
    controller->_customStoryboard = customStoryboard;
    controller.resultBlock = resultBlock;
    controller.options = options;
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    
    return controller;
}

+ (instancetype)startPickerWithTarget:(id)target
                              options:(NBUImagePickerOptions)options
                     customStoryboard:(UIStoryboard *)customStoryboard
                          resultBlock:(NBUImagePickerResultBlock)resultBlock
{
    NBUImagePickerController * controller = [self pickerWithOptions:options
                                                   customStoryboard:customStoryboard
                                                        resultBlock:resultBlock];
    [controller startPickerWithTarget:target];
    return controller;
}

- (void)startPickerWithTarget:(id)target
{
    // No need to prompt?
    if (self.options & NBUImagePickerOptionDisableCamera ||
        self.options & NBUImagePickerOptionDisableLibrary ||
        self.options & NBUImagePickerOptionDoNotStartWithPrompt)
    {
        [self _startPickerWithTarget:target];
        return;
    }
    
    // Otherwise use a prompt
    NSString * cancel = NBULocalizedString(@"NBUImagePickerController Cancel prompt actionSheet", @"Cancel");
    NSString * takePicture = NBULocalizedString(@"NBUImagePickerController Take picture actionSheet", @"Take a picture");
    NSString * chooseImage = NBULocalizedString(@"NBUImagePickerController Choose image actionSheet", @"Choose an image");
    NBUActionSheet * actionSheet = [[NBUActionSheet alloc] initWithTitle:nil
                                                       cancelButtonTitle:cancel
                                                  destructiveButtonTitle:nil
                                                       otherButtonTitles:@[takePicture, chooseImage]
                                                     selectedButtonBlock:^(NSInteger buttonIndex)
                                    {
                                        self.rootViewController = (buttonIndex == 0) ? self.cameraController : self.libraryController;
                                        [self _startPickerWithTarget:target];
                                    }
                                                       cancelButtonBlock:^
                                    {
                                        if (self.resultBlock)
                                        {
                                            self.resultBlock(nil);
                                        }
                                    }];
    [actionSheet showFrom:target];
}

- (void)_startPickerWithTarget:(id)target
{
    // Resolve a target controller
    UIViewController * targetController = target;
    if ([target isKindOfClass:[UIView class]])
    {
        targetController = ((UIView *)target).viewController;
    }
    
    [targetController presentViewController:self
                                   animated:YES
                                 completion:nil];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // Programatical initialization, override in subclasses or create picker in custom Storyboard
        self.navigationBar.barStyle = UIBarStyleBlack;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        {
            self.navigationBar.tintColor = UIColor.lightGrayColor;
        }
    }
    return self;
}

#pragma mark - Orientation handling

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

#pragma mark - Images and Media Info

- (NSMutableArray *)currentMediaInfos
{
    return _mediaInfos;
}

#pragma mark - Customization

- (void)setOptions:(NBUImagePickerOptions)options
{
    if (_mediaInfos)
    {
        NBULogError(@"Picker options can only be set once at initialization!");
        return;
    }
    
    // No camera?
    if (![NBUCameraViewController isCameraAvailable])
    {
        NBULogDebug(@"Options: No camera available.");
        options |= NBUImagePickerOptionDisableCamera;
    }
    
    // Filters not available?
    #if !__has_include("NBUFilters.h")
        NBULogDebug(@"Options: Filters not available.");
        options |= NBUImagePickerOptionDisableFilters;
    #endif
    
    NBULogInfo(@"Picker options: %lx", (long)options);
    _options = options;
    
    // Initilization
    _returnMediaInfoMode = (options & NBUImagePickerOptionReturnMediaInfo) == NBUImagePickerOptionReturnMediaInfo;
    _singleImageMode = (options & NBUImagePickerOptionMultipleImages) != NBUImagePickerOptionMultipleImages;
    _mediaInfos = [NSMutableArray array];
    _previousSelectedAssetPaths = [NSMutableDictionary dictionary];
    
    // Configure the root controller
    if (!self.rootViewController)
    {
        // Set it using the options
        if ((self.cameraController &&
             !(options & (NBUImagePickerOptionStartWithLibrary ^ NBUImagePickerOptionDoNotStartWithPrompt))) ||
            !self.libraryController)
        {
            self.rootViewController = self.cameraController;
        }
        else
        {
            self.rootViewController = self.libraryController;
        }
    }
    
    // Allow customization
    [self finishConfiguringControllersWithOptions:options];
}

- (IBAction)goToNextStep:(id)sender
{
    [self prepareToGoToNextStep];
    
    // *** Override to customize flow ***
    
    // Edit?
    if (self.editController &&
        (self.topViewController == self.cameraController ||
         self.topViewController == self.assetsGroupController))
    {
        [self editImages];
        return;
    }
    
    // Confirm?
    if (self.confirmController &&
        self.topViewController != self.confirmController)
    {
        [self confirmImages];
        return;
    }
    
    // Else just finish the picker
    [self finishPicker:self];
}

- (void)prepareToGoToNextStep
{
    // *** Override if you need to take some actions before going to the next step ***
    
    // First refresh media infos if nedeed
    if (self.topViewController == self.editController)
    {
        _mediaInfos = self.editController.editedMediaInfos;
    }
}

- (void)finishConfiguringControllersWithOptions:(NBUImagePickerOptions)options
{
    // *** Override in subclasses if needed ***
}

#pragma mark - Camera controller

- (NBUCameraViewController *)cameraController
{
    // Camera disabled?
    if (self.options & NBUImagePickerOptionDisableCamera)
    {
        return nil;
    }
    
    // Instantiate camera
    if (!_cameraController)
    {
        NBULogDebug(@"Options: Camera enabled");
        
        _cameraController = [NBUImagePickerController instantiateViewControllerWithIdentifier:@"cameraController"
                                                                             customStoryboard:_customStoryboard];
        
        // Configure controller
        if (self.options & NBUImagePickerOptionDisableLibrary)
        {
            _cameraController.navigationItem.rightBarButtonItem = nil;
        }
        _cameraController.supportedInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
        _cameraController.singlePictureMode = self.singleImageMode;
        
        // Configure capture block
        __weak NBUImagePickerController * weakSelf = self;
        _cameraController.captureResultBlock = ^(UIImage * image,
                                                 NSError * error)
        {
            if (!error && image)
            {
                NBUMediaInfo * mediaInfo = [NBUMediaInfo mediaInfoWithOriginalImage:[image imageWithOrientationUp]];
                
                if (weakSelf.singleImageMode)
                {
                    weakSelf.currentMediaInfos[0] = mediaInfo;
                }
                else
                {
                    [weakSelf.currentMediaInfos insertObject:mediaInfo
                                                     atIndex:0];
                }
                
                [weakSelf goToNextStep:weakSelf];
            }
        };
    }
    
    return _cameraController;
}

#pragma mark - Library controller

- (NBUAssetsLibraryViewController *)libraryController
{
    // Library disabled?
    if (self.options & NBUImagePickerOptionDisableLibrary)
    {
        return nil;
    }
    
    // Instantiate library
    if (!_libraryController)
    {
        NBULogDebug(@"Options: Library enabled");
        
        _libraryController = [NBUImagePickerController instantiateViewControllerWithIdentifier:@"libraryController"
                                                                              customStoryboard:_customStoryboard];
        
        // Configure controller
        _libraryController.customBackButtonTitle = NBULocalizedString(@"NBUImagePickerController libraryController.customBackButtonTitle", @"Albums");
        if (self.options & NBUImagePickerOptionDisableCamera)
        {
            _libraryController.navigationItem.rightBarButtonItem = nil;
        }
        _libraryController.assetsGroupController = self.assetsGroupController;
    }
    
    return _libraryController;
}

- (NBUAssetsGroupViewController *)assetsGroupController
{
    // Library (and group) disabled?
    if (self.options & NBUImagePickerOptionDisableLibrary)
    {
        return nil;
    }
    
    // Instantiate group
    if (!_assetsGroupController)
    {
        NBULogDebug(@"Options: Library groups enabled");
        
        _assetsGroupController = [NBUImagePickerController instantiateViewControllerWithIdentifier:@"assetsGroupController"
                                                                                  customStoryboard:_customStoryboard];
        
        // Configure controller
        _assetsGroupController.reverseOrder = YES;
        _assetsGroupController.navigationItem.leftBarButtonItem = nil; // Allow back button
        _assetsGroupController.customBackButtonTitle = NBULocalizedString(@"NBUImagePickerController assetsGroupController.customBackButtonTitle", @"Library");
        if (self.options & NBUImagePickerOptionDisableCamera)
        {
            _assetsGroupController.navigationItem.rightBarButtonItem = nil;
        }
        
        // Single image mode
        if (_singleImageMode)
        {
            _assetsGroupController.selectionCountLimit = 1;
            _assetsGroupController.clearsSelectionOnViewWillAppear = YES;
            
            __weak NBUImagePickerController * weakSelf = self;
            _assetsGroupController.selectionChangedBlock = ^(NSArray * selectedAssets)
            {
                if (selectedAssets.count > 0)
                {
                    [weakSelf _finishAssetsSelection];
                }
            };
        }
        
        // Multiple images mode
        else
        {
            // Replace the camera button by a continue button if not customized
            if (!_assetsGroupController.navigationItem.rightBarButtonItem ||
                _assetsGroupController.navigationItem.rightBarButtonItem.tag < 0)
            {
                UIBarButtonItem * continueButton = [[UIBarButtonItem alloc] initWithTitle:NBULocalizedString(@"NBUImagePickerController assetsGroupController.continueButton", @"Continue")
                                                                                    style:UIBarButtonItemStyleDone
                                                                                   target:self
                                                                                   action:@selector(_finishAssetsSelection)];
                _assetsGroupController.continueButton = continueButton;
                _assetsGroupController.navigationItem.rightBarButtonItem = continueButton;
            }
        }
    }
    
    return _assetsGroupController;
}

- (void)_finishAssetsSelection
{
    NBULogTrace();
    
    NSArray * selectedAssets = self.assetsGroupController.selectedAssets;
    
    // Remove no longer selected assets
    NBUAsset * asset;
    NSString * path;
    NBUMediaInfo * mediaInfo;
    BOOL stillSelected;
    for (NSString * previouslySelectedAssetPath in _previousSelectedAssetPaths.allKeys)
    {
        stillSelected = NO;
        for (asset in selectedAssets)
        {
            path = asset.URL.absoluteString;
            if ([previouslySelectedAssetPath isEqualToString:path])
            {
                stillSelected = YES;
                break;
            }
        }
        
        if (!stillSelected)
        {
            mediaInfo = _previousSelectedAssetPaths[previouslySelectedAssetPath];
            [_mediaInfos removeObject:mediaInfo];
            [_previousSelectedAssetPaths removeObjectForKey:previouslySelectedAssetPath];
        }
    }
    
    // Add newly selected assets
    for (asset in selectedAssets)
    {
        path = asset.URL.absoluteString;
        if (!_previousSelectedAssetPaths[path])
        {
            mediaInfo = [NBUMediaInfo mediaInfoWithAttributes:
                         @{
                          NBUMediaInfoOriginalAssetKey       : asset,
                          NBUMediaInfoOriginalMediaURLKey    : asset.URL
                         }];
            
            if (_singleImageMode)
            {
                _mediaInfos[0] = mediaInfo;
            }
            else
            {
                [_mediaInfos addObject:mediaInfo];
                _previousSelectedAssetPaths[path] = mediaInfo;
            }
        }
    }

    [self goToNextStep:self];
}

#pragma mark - Edit controller

- (NBUEditMultiImageViewController *)editController
{
    // Edition disabled?
    if ((self.options & NBUImagePickerOptionDisableCrop) &&
        (self.options & NBUImagePickerOptionDisableFilters))
    {
        return nil;
    }

    // Instantiate the image editor
    if (!_editController)
    {
        NBULogDebug(@"Options: Edition enabled (Crop: %@, Filters %@)",
                    NBUStringFromBOOL(!(self.options & NBUImagePickerOptionDisableCrop)),
                    NBUStringFromBOOL(!(self.options & NBUImagePickerOptionDisableFilters)));
        
        // No crop?
        if (self.options & NBUImagePickerOptionDisableCrop)
        {
            _editController = [NBUImagePickerController instantiateViewControllerWithIdentifier:@"editControllerNoCrop"
                                                                               customStoryboard:_customStoryboard];
        }
        // No filters?
        else if (self.options & NBUImagePickerOptionDisableFilters)
        {
            _editController = [NBUImagePickerController instantiateViewControllerWithIdentifier:@"editControllerNoFilters"
                                                                               customStoryboard:_customStoryboard];
        }
        // Crop and filters
        else
        {
            _editController = [NBUImagePickerController instantiateViewControllerWithIdentifier:@"editController"
                                                                               customStoryboard:_customStoryboard];
        }
        
        // Enable back button
        _editController.navigationItem.leftBarButtonItem = nil;
        
        // UI customization
        _editController.navigationItem.rightBarButtonItem.title = NBULocalizedString(@"NBUImagePickerController editController rightBarButtonItem.title", @"Next");
        if (!_editController.navigationItem.rightBarButtonItem.action)
        {
            _editController.navigationItem.rightBarButtonItem.action = @selector(goToNextStep:);
            _editController.navigationItem.rightBarButtonItem.target = self;
        }
        _editController.customBackButtonTitle = NBULocalizedString(@"NBUImagePickerController editController.customBackButtonTitle", @"Edit");
        if (_singleImageMode)
        {
            _editController.navigationItem.titleView = nil;
            _editController.navigationItem.title = NBULocalizedString(@"NBUImagePickerController editController title", @"Edit");
        }
        
        // Set up crop and working sizes
        CGFloat scale = [UIScreen mainScreen].scale;
        _editController.workingSize = CGSizeMake(450.0 * scale,
                                                 450.0 * scale);
        
        // Manually call viewDidLoad
        // [_editController viewDidLoad]; <- No longer needed it seems
    }
    
    return _editController;
}

- (void)editImages
{
    NBULogInfo(@"%@: %@", THIS_METHOD, _mediaInfos);
    
    // Prepare the edit controller
    _editController.mediaInfos = _mediaInfos;
    
    [self pushViewController:_editController
                    animated:YES];
}

#pragma mark - Confirm controller

- (NBUGalleryViewController *)confirmController
{
    // Gallery disabled?
    if (self.options & NBUImagePickerOptionDisableConfirmation)
    {
        return nil;
    }
    
    // Instantiate gallery
    if (!_confirmController)
    {
        NBULogDebug(@"Options: Confirmation gallery enabled");
        
        _confirmController = [NBUImagePickerController instantiateViewControllerWithIdentifier:@"confirmController"
                                                                              customStoryboard:_customStoryboard];
        
        // Configure controller
        _confirmController.navigationItem.title = NBULocalizedString(@"NBUImagePickerController confirmController title", @"Confirm");
        _confirmController.updatesBars = NO;
    }
    
    return _confirmController;
}

- (void)confirmImages
{
    NBULogInfo(@"%@: %@", THIS_METHOD, _mediaInfos);
    
    // Prepare the gallery controller
    self.confirmController.objectArray = _mediaInfos;
    
    [self pushViewController:self.confirmController
                    animated:YES];
}

#pragma mark - Actions

- (IBAction)toggleSource:(id)sender
{
    NSMutableArray * controllers = [NSMutableArray arrayWithArray:self.viewControllers];
    if (self.topViewController == self.cameraController)
    {
        // Replace camera
        [controllers removeLastObject];
        if (!_controllersToToggleBack)
        {
            _controllersToToggleBack = [NSArray arrayWithObjects:self.libraryController, nil];
        }
        [controllers insertObjects:_controllersToToggleBack
                         atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(controllers.count,
                                                                                      _controllersToToggleBack.count)]];
    }
    else
    {
        // Remove one or two assets controllers?
        if (![self.viewControllers containsObject:self.assetsGroupController])
        {
            // One
            [controllers removeLastObject];
            _controllersToToggleBack = [NSArray arrayWithObjects:self.libraryController, nil];
        }
        else
        {
            // Two
            [controllers removeLastObject];
            [controllers removeLastObject];
            _controllersToToggleBack = [NSArray arrayWithObjects:self.libraryController, self.assetsGroupController, nil];
        }
        [controllers addObjectsFromArray:[NSArray arrayWithObjects:self.cameraController, nil]];
    }
    
    NBULogDebug(@"%@ %@ -> %@", THIS_METHOD, self.viewControllers.shortDescription, controllers.shortDescription);
    self.viewControllers = controllers;
    
    // Force refresh orientation
    [self forceOrientationRefresh];
}

- (IBAction)finishPicker:(id)sender
{
    // Save images?
    BOOL saveTaken = (self.options & NBUImagePickerOptionSaveTakenImages) == NBUImagePickerOptionSaveTakenImages;
    BOOL saveEdited = (self.options & NBUImagePickerOptionSaveEditedImages) == NBUImagePickerOptionSaveEditedImages;
    if (saveTaken || saveEdited)
    {
        BOOL sourceIsCamera;
        BOOL imageIsEdited;
        for (NSUInteger index = 0; index < _mediaInfos.count; index++)
        {
            sourceIsCamera = ((NBUMediaInfo *)_mediaInfos[index]).source == NBUMediaInfoSourceCamera;
            imageIsEdited = ((NBUMediaInfo *)_mediaInfos[index]).edited;
            if ((saveTaken && sourceIsCamera) ||
                (saveEdited && imageIsEdited))
            {
                [[NBUAssetsLibrary sharedLibrary] saveImageToCameraRoll:((NBUMediaInfo *)_mediaInfos[index]).editedImage
                                                               metadata:nil
                                               addToAssetsGroupWithName:self.targetLibraryAlbumName
                                                            resultBlock:^(NSURL * assetURL,
                                                                          NSError * error)
                 {
                     if (!error && assetURL)
                     {
                         ((NBUMediaInfo *)_mediaInfos[index]).attributes[NBUMediaInfoEditedMediaURLKey] = assetURL;
                     }
                 }];
            }
        }
    }
    
    // Prepare result
    NSMutableArray * result = _mediaInfos;
    if (!_returnMediaInfoMode)
    {
        result = [NSMutableArray arrayWithCapacity:_mediaInfos.count];
        for (NSUInteger index = 0; index < _mediaInfos.count; index++)
        {
            [result addObject:((NBUMediaInfo *)_mediaInfos[index++]).editedImage];
        }
    }
    
    // Call result block
    if (self.resultBlock)
    {
        self.resultBlock(result);
    }
    
    // Dismiss
    [self dismiss:self];
}

- (IBAction)dismiss:(id)sender
{
    NBULogTrace();
    
    // Was cancelled by the user?
    if (sender != self)
    {
        NBULogInfo(@"Picker cancelled by user");
        
        if (self.resultBlock)
        {
            self.resultBlock(nil);
        }
    }
    
    [self dismissViewControllerAnimated:YES
                             completion:NULL];
}

@end

