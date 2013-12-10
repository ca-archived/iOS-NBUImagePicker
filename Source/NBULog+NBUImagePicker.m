//
//  NBULog+NBUImagePicker.m
//  NBUImagePicker
//
//  Created by Ernesto Rivera on 2012/12/12.
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

#ifdef COCOAPODS_POD_AVAILABLE_NBULog

#import "NBULog+NBUImagePicker.h"
#import <NBULog/NBULogContextDescription.h>

#define MAX_MODULES 10

static int _imagePickerLogLevel;
static int _imagePickerModulesLogLevel[MAX_MODULES];

@implementation NBULog (NBUImagePicker)

+ (void)load
{
    // Default levels
    [self setImagePickerLogLevel:LOG_LEVEL_DEFAULT];
    
    // Register the NBUImagePicker log context
    [NBULog registerContextDescription:[NBULogContextDescription descriptionWithName:@"NBUImagePicker"
                                                                             context:NBUIMAGEPICKER_LOG_CONTEXT
                                                                     modulesAndNames:@{@(NBUIMAGEPICKER_MODULE_CAMERA)  : @"Camera",
                                                                                       @(NBUIMAGEPICKER_MODULE_ASSETS)  : @"Assets",
                                                                                       @(NBUIMAGEPICKER_MODULE_IMAGE)   : @"Image",
                                                                                       @(NBUIMAGEPICKER_MODULE_GALLERY) : @"Gallery"}
                                                                   contextLevelBlock:^{ return [NBULog imagePickerLogLevel]; }
                                                                setContextLevelBlock:^(int level) { [NBULog setImagePickerLogLevel:level]; }
                                                          contextLevelForModuleBlock:^(int module) { return [NBULog imagePickerLogLevelForModule:module]; }
                                                       setContextLevelForModuleBlock:^(int module, int level) { [NBULog setImagePickerLogLevel:level forModule:module]; }]];
}

+ (int)imagePickerLogLevel
{
    return _imagePickerLogLevel;
}

+ (void)setImagePickerLogLevel:(int)LOG_LEVEL_XXX
{
#ifdef DEBUG
    _imagePickerLogLevel = LOG_LEVEL_XXX == LOG_LEVEL_DEFAULT ? LOG_LEVEL_INFO : LOG_LEVEL_XXX;
#else
    _imagePickerLogLevel = LOG_LEVEL_XXX == LOG_LEVEL_DEFAULT ? LOG_LEVEL_WARN : LOG_LEVEL_XXX;
#endif
    
    // Reset all modules' levels
    for (int i = 0; i < MAX_MODULES; i++)
    {
        [self setImagePickerLogLevel:LOG_LEVEL_DEFAULT
                   forModule:i];
    }
}

+ (int)imagePickerLogLevelForModule:(int)NBUIMAGEPICKER_MODULE_XXX
{
    int logLevel = _imagePickerModulesLogLevel[NBUIMAGEPICKER_MODULE_XXX];
    
    // Fallback to the default log level if necessary
    return logLevel == LOG_LEVEL_DEFAULT ? _imagePickerLogLevel : logLevel;
}

+ (void)setImagePickerLogLevel:(int)LOG_LEVEL_XXX
             forModule:(int)NBUIMAGEPICKER_MODULE_XXX
{
    _imagePickerModulesLogLevel[NBUIMAGEPICKER_MODULE_XXX] = LOG_LEVEL_XXX;
}

@end

#endif

