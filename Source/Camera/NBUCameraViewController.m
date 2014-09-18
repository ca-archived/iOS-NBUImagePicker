//
//  NBUCameraViewController.m
//  NBUImagePicker
//
//  Created by Ernesto Rivera on 2012/11/12.
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

#import "NBUCameraViewController.h"
#import "NBUImagePickerPrivate.h"
#import <RBVolumeButtons@PTEz/RBVolumeButtons.h>

@implementation NBUCameraViewController
{
    RBVolumeButtons * _buttonStealer;
}

+ (BOOL)isCameraAvailable
{
#if TARGET_IPHONE_SIMULATOR
    // Simulator has a mock camera
    return YES;
#endif
    
    // Check with UIImagePickerController
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (void)commonInit
{
    [super commonInit];
    
    self.takesPicturesWithVolumeButtons = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the camera view
    self.targetResolution = _targetResolution;
    self.captureResultBlock = _captureResultBlock;
    self.savePicturesToLibrary = _savePicturesToLibrary;
    self.targetLibraryAlbumName = _targetLibraryAlbumName;
    
    __weak NBUCameraViewController * weakSelf = self;
    _cameraView.flashButtonConfigurationBlock = ^(id<UIButton> button, AVCaptureFlashMode mode)
    {
        weakSelf.flashLabel.hidden = button.hidden;
        
        switch (mode)
        {
            case AVCaptureFlashModeOn:
                weakSelf.flashLabel.text = NBULocalizedString(@"NBUCameraViewController FlashLabel On", @"On");
                break;
                
            case AVCaptureFlashModeOff:
                weakSelf.flashLabel.text = NBULocalizedString(@"NBUCameraViewController FlashLabel Off", @"Off");
                break;
                
            case AVCaptureFlashModeAuto:
            default:
                weakSelf.flashLabel.text = NBULocalizedString(@"NBUCameraViewController FlashLabel Auto", @"Auto");
                break;
        }
    };
    
    // Configure title
    if (!self.navigationItem.titleView && [self.navigationItem.title hasPrefix:@"@@"])
    {
        if (!_cameraView.userDeniedAccess && !_cameraView.restrictedAccess)
        {
            self.navigationItem.title = NBULocalizedString(@"NBUImagePickerController CameraTitle", @"Camera");
        }
        else
        {
            self.navigationItem.title = NBULocalizedString(@"NBUImagePickerController CameraAccessDeniedTitle", @"Camera Access Denied");
        }
    }
    
    // Configure access denied view if needed
    if (_accessDeniedView)
    {
        _accessDeniedView.hidden = (!_cameraView.userDeniedAccess && !_cameraView.restrictedAccess);
    }
}

- (void)viewDidUnload
{
    _cameraView = nil;
    
    [self setFlashLabel:nil];
    [super viewDidUnload];
}

- (void)setTakesPicturesWithVolumeButtons:(BOOL)takesPicturesWithVolumeButtons
{
    _takesPicturesWithVolumeButtons = takesPicturesWithVolumeButtons;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Start stealing buttons
    if (_takesPicturesWithVolumeButtons)
    {
        if (!_buttonStealer)
        {
            __weak NBUCameraViewController * weakSelf = self;
            ButtonBlock block = ^
            {
                [weakSelf.cameraView takePicture:weakSelf];
            };
            _buttonStealer = [RBVolumeButtons new];
            _buttonStealer.upBlock = block;
            _buttonStealer.downBlock = block;
        }
        
        [_buttonStealer startStealingVolumeButtonEvents];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Stop stealing buttons
    if (_takesPicturesWithVolumeButtons)
    {
        [_buttonStealer stopStealingVolumeButtonEvents];
    }
}

- (void)setTargetResolution:(CGSize)targetResolution
{
    _targetResolution = targetResolution;
    
    if (_cameraView)
    {
        _cameraView.targetResolution = targetResolution;
    }
}

- (void)setCaptureResultBlock:(NBUCapturePictureResultBlock)captureResultBlock
{
    _captureResultBlock = captureResultBlock;
    
    if (_cameraView)
    {
        _cameraView.captureResultBlock = captureResultBlock;
    }
}

- (void)setSavePicturesToLibrary:(BOOL)savePicturesToLibrary
{
    _savePicturesToLibrary = savePicturesToLibrary;
    
    if (_cameraView)
    {
        _cameraView.savePicturesToLibrary = savePicturesToLibrary;
    }
}

- (void)setTargetLibraryAlbumName:(NSString *)targetLibraryAlbumName
{
    _targetLibraryAlbumName = targetLibraryAlbumName;
    
    if (_cameraView)
    {
        _cameraView.targetLibraryAlbumName = targetLibraryAlbumName;
    }
}

@end

