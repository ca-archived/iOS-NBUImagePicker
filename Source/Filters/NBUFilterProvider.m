//
//  NBUFilterProvider.m
//  NBUImagePicker
//
//  Created by Ernesto Rivera on 2012/05/03.
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

#import "NBUFilterProvider.h"
#import "NBUImagePickerPrivate.h"

// Built-in filter types
NSString * const NBUFilterTypeNone              = @"none";
NSString * const NBUFilterTypeContrast          = @"contrast";
NSString * const NBUFilterTypeBrightness        = @"brightness";
NSString * const NBUFilterTypeSaturation        = @"saturation";
NSString * const NBUFilterTypeExposure          = @"exposure";
NSString * const NBUFilterTypeSharpen           = @"sharpen";
NSString * const NBUFilterTypeGamma             = @"gamma";
NSString * const NBUFilterTypeAuto              = @"auto";
NSString * const NBUFilterTypeMonochrome        = @"monochrome";
NSString * const NBUFilterTypeMultiplyBlend     = @"multiplyBlend";
NSString * const NBUFilterTypeAdditiveBlend     = @"additiveBlend";
NSString * const NBUFilterTypeAlphaBlend        = @"alphaBlend";
NSString * const NBUFilterTypeSourceOver        = @"sourceOver";
NSString * const NBUFilterTypeToneCurve         = @"toneCurve";
NSString * const NBUFilterTypeFisheye           = @"fisheye";
NSString * const NBUFilterTypeMaskBlur          = @"maskBlur";
NSString * const NBUFilterTypeGroup             = @"group";

// Static variables
static NSMutableArray * _providers;
static NSArray * _availableFilterTypes;
static NSDictionary * _localizedFilterNames;

@implementation NBUFilterProvider

+ (void)initialize
{
    if (self == [NBUFilterProvider class])
    {
        _providers = [NSMutableArray array];
        
        // Add GPUImage
        [self addProvider:[NBUGPUImageFilterProvider class]];
        
        // Add CoreImage
        [self addProvider:[NBUCoreImageFilterProvider class]];
    }
}

+ (void)addProvider:(Class<NBUFilterProvider>)provider
{
    [_providers addObject:provider];
    
    // Reset available filters
    _availableFilterTypes = nil;
}

+ (NSString *)localizedNameForFilterWithType:(NSString *)type
{
    if (!_localizedFilterNames)
    {
        // Read the localized filter names
        _localizedFilterNames = @
        {
            NBUFilterTypeNone           : NBULocalizedString(@"NBUFilterProvider None filter", @"None"),
            NBUFilterTypeContrast       : NBULocalizedString(@"NBUFilterProvider Contrast filter", @"Contrast"),
            NBUFilterTypeBrightness     : NBULocalizedString(@"NBUFilterProvider Brightness filter", @"Brightness"),
            NBUFilterTypeSaturation     : NBULocalizedString(@"NBUFilterProvider Saturation filter", @"Saturation"),
            NBUFilterTypeExposure       : NBULocalizedString(@"NBUFilterProvider Exposure filter", @"Exposure"),
            NBUFilterTypeSharpen        : NBULocalizedString(@"NBUFilterProvider Sharpen filter", @"Sharpen"),
            NBUFilterTypeGamma          : NBULocalizedString(@"NBUFilterProvider filter", @"Gamma"),
            NBUFilterTypeAuto           : NBULocalizedString(@"NBUFilterProvider Auto filter", @"Auto"),
            NBUFilterTypeMonochrome     : NBULocalizedString(@"NBUFilterProvider Monochrome filter", @"Monochrome"),
            NBUFilterTypeMultiplyBlend  : NBULocalizedString(@"NBUFilterProvider Multiply blend filter", @"Multiply blend"),
            NBUFilterTypeAdditiveBlend  : NBULocalizedString(@"NBUFilterProvider Additive blend filter", @"Additive blend"),
            NBUFilterTypeAlphaBlend     : NBULocalizedString(@"NBUFilterProvider Alpha blend filter", @"Alpha blend"),
            NBUFilterTypeSourceOver     : NBULocalizedString(@"NBUFilterProvider Source over filter", @"Source over"),
            NBUFilterTypeToneCurve      : NBULocalizedString(@"NBUFilterProvider Curve adjustement filter", @"Curve adjustement"),
            NBUFilterTypeFisheye        : NBULocalizedString(@"NBUFilterProvider Fisheye filter", @"Fisheye"),
            NBUFilterTypeMaskBlur       : NBULocalizedString(@"NBUFilterProvider Mask blur filter", @"Mask blur"),
            NBUFilterTypeGroup          : NBULocalizedString(@"NBUFilterProvider Filter group filter", @"Filter group")
        };
    }
    return _localizedFilterNames[type];
}

#pragma mark - NBUFilterProvider protocol

+ (NSArray *)availableFilterTypes
{
    // Cached?
    if (_availableFilterTypes)
    {
        return _availableFilterTypes;
    }
    
    // Check available types
    NSMutableSet * filterTypes = [NSMutableSet set];
    for (Class<NBUFilterProvider> provider in _providers)
    {
        [filterTypes addObjectsFromArray:[provider availableFilterTypes]];
    }
    
    // Finish with the "None" filter
    _availableFilterTypes = [@[NBUFilterTypeNone] arrayByAddingObjectsFromArray:filterTypes.allObjects];
    
    NBULogInfo(@"Available filter types: %@", _availableFilterTypes);
    
    return _availableFilterTypes;
}

+ (NSArray *)availableFilters
{
    NSMutableArray * filters = [NSMutableArray array];
    NBUFilter * filter;
    NSArray * filterTypes = [self availableFilterTypes];
    for (NSString * type in filterTypes)
    {
        filter = [self filterWithName:nil
                                 type:type
                               values:nil];
        [filters addObject:filter];
    }
    return filters;
}

+ (NBUFilter *)filterWithName:(NSString *)name
                         type:(NSString *)type
                       values:(NSDictionary *)values
{
    // Handle the "None" filter
    if ([type isEqualToString:NBUFilterTypeNone])
    {
        return [NBUFilter filterWithName:name ? name : [self localizedNameForFilterWithType:type]
                                    type:type
                                  values:nil
                              attributes:nil
                                provider:nil
                    configureFilterBlock:NULL];
    }
    
    // Check available types
    for (Class<NBUFilterProvider> provider in _providers)
    {
        if ([[provider availableFilterTypes] containsObject:type])
        {
            return [provider filterWithName:name ? name : [self localizedNameForFilterWithType:type]
                                       type:type
                                     values:values];
        }
    }
    
    NBULogWarn(@"NBUFilter of type '%@' is not available", type);
    return nil;
}

+ (UIImage *)applyFilters:(NSArray *)filters
                  toImage:(UIImage *)image
{
    if (!filters.count)
        return image;
    
    // Expand filter groups
    NSMutableArray * expandedFilters = [NSMutableArray array];
    for (NBUFilter * filter in filters)
    {
        // Add normal filters
        if (![filter isKindOfClass:[NBUFilterGroup class]])
        {
            [expandedFilters addObject:filter];
        }
        
        // And add filters from non disabled group filters
        else if (filter.enabled)
        {
            [expandedFilters addObjectsFromArray:((NBUFilterGroup *)filter).filters];
        }
    }
    
    // Order filters by provider
    Class<NBUFilterProvider> currentProvider;
    NSMutableArray * filtersByProvider = [NSMutableArray array];
    NSMutableArray * sameProviderFilters;
    for (NBUFilter * filter in expandedFilters)
    {
        // Skip disabled filters
        if (!filter.enabled)
            continue;
        
        // Different provider?
        if (filter.provider != currentProvider)
        {
            currentProvider = filter.provider;
            sameProviderFilters = [NSMutableArray arrayWithObject:filter];
            [filtersByProvider addObject:sameProviderFilters];
        }
        
        // Same provider
        else
        {
            [sameProviderFilters addObject:filter];
        }
    }
    
    NBULogVerbose(@"filtersByProvider: %@ image size: %@", filtersByProvider, NSStringFromCGSize(image.size));
    
    // Process the image
    UIImage * filteredImage = image;
    
    for (sameProviderFilters in filtersByProvider)
    {
        currentProvider = ((NBUFilter *)sameProviderFilters[0]).provider;
        filteredImage = [currentProvider applyFilters:sameProviderFilters
                                              toImage:filteredImage];
    }
    
    return filteredImage;
}

@end

