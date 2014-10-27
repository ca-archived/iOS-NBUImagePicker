//
//  NBUImagePicker.m
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

#import "NBUImagePicker.h"

@implementation NBUImagePicker

+ (NSBundle *)bundle
{
    static NSBundle * _resourcesBundle;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      NSString * resourcesPath = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"NBUImagePicker.bundle"];
                      _resourcesBundle = [NSBundle bundleWithPath:resourcesPath];
                  });
    
    return _resourcesBundle;
}

+ (UIStoryboard *)mainStoryboard
{
    static UIStoryboard * _mainStoryboard;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      _mainStoryboard = [UIStoryboard storyboardWithName:@"NBUImagePicker"
                                                                  bundle:self.bundle];
                  });
    
    return _mainStoryboard;
}

@end

