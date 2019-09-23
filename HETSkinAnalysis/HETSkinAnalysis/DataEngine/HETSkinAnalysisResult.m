//
//  HETSkinAnalysisResult.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/18.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETSkinAnalysisResult.h"


#pragma mark - HETSkinInfoOil

@implementation HETSkinInfoOil
- (id)copyWithZone:(NSZone *)zone
{
    HETSkinInfoOil *copyObj = [[[self class] allocWithZone:zone]init];
    copyObj.level = self.level;
    copyObj.facePart = self.facePart;
    return copyObj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

+ (instancetype)modelWithJSON:(NSDictionary*)json
{
    if (!json) {
        return nil;
    }
    return [[self alloc]initWithJSON:json];
}

- (instancetype)initWithJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:json];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end

#pragma mark - HETSkinInfoMoisture
@implementation HETSkinInfoMoisture
- (id)copyWithZone:(NSZone *)zone
{
    HETSkinInfoMoisture *copyObj = [[[self class] allocWithZone:zone]init];
    copyObj.level = self.level;
    copyObj.facePart = self.facePart;
    copyObj.className = self.className;
    return copyObj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

+ (instancetype)modelWithJSON:(NSDictionary*)json
{
    if (!json) {
        return nil;
    }
    return [[self alloc]initWithJSON:json];
}


- (instancetype)initWithJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:json];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end

#pragma mark - HETSkinInfoAcne
@implementation HETSkinInfoAcne
- (id)copyWithZone:(NSZone *)zone
{
    HETSkinInfoAcne *copyObj = [[[self class] allocWithZone:zone]init];
    copyObj.level = self.level;
    copyObj.facePart = self.facePart;
    copyObj.number = self.number;
    copyObj.acneTypeId = self.acneTypeId;
    return copyObj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

+ (instancetype)modelWithJSON:(NSDictionary*)json
{
    if (!json) {
        return nil;
    }
    return [[self alloc]initWithJSON:json];
}


- (instancetype)initWithJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:json];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end

#pragma mark - HETSkinInfoEyeShape
@implementation HETSkinInfoEyeShape
- (id)copyWithZone:(NSZone *)zone
{
    HETSkinInfoEyeShape *copyObj = [[[self class] allocWithZone:zone]init];
    copyObj.narrow = self.narrow;
    copyObj.updown = self.updown;
    copyObj.eyelid = self.eyelid;
    return copyObj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

+ (instancetype)modelWithJSON:(NSDictionary*)json
{
    if (!json) {
        return nil;
    }
    return [[self alloc]initWithJSON:json];
}

- (instancetype)initWithJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:json];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end

#pragma mark - HETSkinInfoEyeBrow
@implementation HETSkinInfoEyeBrow
- (id)copyWithZone:(NSZone *)zone
{
    HETSkinInfoEyeBrow *copyObj = [[[self class] allocWithZone:zone]init];
    copyObj.left = self.left;
    copyObj.right = self.right;
    return copyObj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

+ (instancetype)modelWithJSON:(NSDictionary*)json
{
    if (!json) {
        return nil;
    }
    return [[self alloc]initWithJSON:json];
}

- (instancetype)initWithJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:json];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end

#pragma mark - HETSkinInfoDarkCircle
@implementation HETSkinInfoDarkCircle
- (id)copyWithZone:(NSZone *)zone
{
    HETSkinInfoDarkCircle *copyObj = [[[self class] allocWithZone:zone]init];
    copyObj.level = self.level;
    copyObj.position = self.position;
    copyObj.type = self.type;
    return copyObj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

+ (instancetype)modelWithJSON:(NSDictionary*)json
{
    if (!json) {
        return nil;
    }
    return [[self alloc]initWithJSON:json];
}

- (instancetype)initWithJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:json];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end

#pragma mark - HETSkinInfoBlackHead
@implementation HETSkinInfoBlackHead
- (id)copyWithZone:(NSZone *)zone
{
    HETSkinInfoBlackHead *copyObj = [[[self class] allocWithZone:zone]init];
    copyObj.level = self.level;
    copyObj.number = self.number;
    return copyObj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

+ (instancetype)modelWithJSON:(NSDictionary*)json
{
    if (!json) {
        return nil;
    }
    return [[self alloc]initWithJSON:json];
}

- (instancetype)initWithJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:json];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end

#pragma mark - HETSkinInfoFacePose
@implementation HETSkinInfoFacePose
- (id)copyWithZone:(NSZone *)zone
{
    HETSkinInfoFacePose *copyObj = [[[self class] allocWithZone:zone]init];
    copyObj.pitch = self.pitch;
    copyObj.roll = self.roll;
    copyObj.yam = self.yam;
    return copyObj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

+ (instancetype)modelWithJSON:(NSDictionary*)json
{
    if (!json) {
        return nil;
    }
    return [[self alloc]initWithJSON:json];
}

- (instancetype)initWithJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:json];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end

#pragma mark - HETSkinInfoFatGranule
@implementation HETSkinInfoFatGranule
- (id)copyWithZone:(NSZone *)zone
{
    HETSkinInfoFatGranule *copyObj = [[[self class] allocWithZone:zone]init];
    copyObj.fatGranuleTypeId = self.fatGranuleTypeId;
    copyObj.level = self.level;
    copyObj.number = self.number;
    return copyObj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

+ (instancetype)modelWithJSON:(NSDictionary*)json
{
    if (!json) {
        return nil;
    }
    return [[self alloc]initWithJSON:json];
}

- (instancetype)initWithJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:json];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end

#pragma mark - HETSkinInfoImageQuality
@implementation HETSkinInfoImageQuality
- (id)copyWithZone:(NSZone *)zone
{
    HETSkinInfoImageQuality *copyObj = [[[self class] allocWithZone:zone]init];
    copyObj.blurType = self.blurType;
    copyObj.lightType = self.lightType;
    return copyObj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

+ (instancetype)modelWithJSON:(NSDictionary*)json
{
    if (!json) {
        return nil;
    }
    return [[self alloc]initWithJSON:json];
}

- (instancetype)initWithJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:json];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end

#pragma mark - HETSkinInfoPigmentation
@implementation HETSkinInfoPigmentation
- (id)copyWithZone:(NSZone *)zone
{
    HETSkinInfoPigmentation *copyObj = [[[self class] allocWithZone:zone]init];
    copyObj.facePart = self.facePart;
    copyObj.level = self.level;
    copyObj.pigmentationTypeId = self.pigmentationTypeId;
    return copyObj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

+ (instancetype)modelWithJSON:(NSDictionary*)json
{
    if (!json) {
        return nil;
    }
    return [[self alloc]initWithJSON:json];
}

- (instancetype)initWithJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:json];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end

#pragma mark - HETSkinInfoPore
@implementation HETSkinInfoPore
- (id)copyWithZone:(NSZone *)zone
{
    HETSkinInfoPore *copyObj = [[[self class] allocWithZone:zone]init];
    copyObj.number = self.number;
    copyObj.level = self.level;
    return copyObj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

+ (instancetype)modelWithJSON:(NSDictionary*)json
{
    if (!json) {
        return nil;
    }
    return [[self alloc]initWithJSON:json];
}

- (instancetype)initWithJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:json];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end

#pragma mark - HETSkinInfoPouch
@implementation HETSkinInfoPouch
- (id)copyWithZone:(NSZone *)zone
{
    HETSkinInfoPouch *copyObj = [[[self class] allocWithZone:zone]init];
    copyObj.exist = self.exist;
    copyObj.level = self.level;
    return copyObj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

+ (instancetype)modelWithJSON:(NSDictionary*)json
{
    if (!json) {
        return nil;
    }
    return [[self alloc]initWithJSON:json];
}

- (instancetype)initWithJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:json];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end

#pragma mark - HETSkinInfoSensitivityCategory
@implementation HETSkinInfoSensitivityCategory
- (id)copyWithZone:(NSZone *)zone
{
    HETSkinInfoSensitivityCategory *copyObj = [[[self class] allocWithZone:zone]init];
    copyObj.facePart = self.facePart;
    copyObj.level = self.level;
    return copyObj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}


+ (instancetype)modelWithJSON:(NSDictionary*)json
{
    if (!json) {
        return nil;
    }
    return [[self alloc]initWithJSON:json];
}

- (instancetype)initWithJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:json];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end

#pragma mark - HETSkinInfoSensitivity

@implementation HETSkinInfoSensitivity
- (id)copyWithZone:(NSZone *)zone
{
    HETSkinInfoSensitivity *copyObj = [[[self class] allocWithZone:zone]init];
    copyObj.sensitivityCategory = [self.sensitivityCategory mutableCopy];
    copyObj.typeId = self.typeId;
    return copyObj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

+ (instancetype)modelWithJSON:(NSDictionary*)json
{
    if (!json) {
        return nil;
    }
    return [[self alloc]initWithJSON:json];
}

- (instancetype)initWithJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:json];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"sensitivityCategory"]) {
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *tagList = (NSArray*)value;
            NSMutableArray *tmpArray = [NSMutableArray array];
            [tagList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                    HETSkinInfoSensitivityCategory *aModel = [HETSkinInfoSensitivityCategory modelWithJSON:obj];
                    if (aModel) {
                        [tmpArray addObject:aModel];
                    }
                }
            }];
            self.sensitivityCategory = [NSArray arrayWithArray:tmpArray];
        }
    }
    else
    {
        [super setValue:value forKey:key];
    }
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"sensitivityCategory" : [HETSkinInfoSensitivityCategory class]};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{ @"sensitivityCategory" : [HETSkinInfoSensitivityCategory class]};
}
@end

#pragma mark - HETSkinInfoWrinkles

@implementation HETSkinInfoWrinkles
- (id)copyWithZone:(NSZone *)zone
{
    HETSkinInfoWrinkles *copyObj = [[[self class] allocWithZone:zone]init];
    copyObj.wrinkleTypeId = self.wrinkleTypeId;
    copyObj.level = self.level;
    return copyObj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

+ (instancetype)modelWithJSON:(NSDictionary*)json
{
    if (!json) {
        return nil;
    }
    return [[self alloc]initWithJSON:json];
}

- (instancetype)initWithJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:json];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}
@end


#pragma mark - HETSkinAnalysisResult
@implementation HETSkinAnalysisResult
- (id)copyWithZone:(NSZone *)zone
{
    HETSkinAnalysisResult *copyObj = [[[self class] allocWithZone:zone]init];
    copyObj.originalImageUrl = self.originalImageUrl;
    copyObj.sex = self.sex;
    copyObj.skinAge = self.skinAge;
    copyObj.skinType = self.skinType;
    copyObj.furrows = self.furrows;
    copyObj.facecolor = self.facecolor;
    copyObj.faceshape = self.faceshape;
    copyObj.pigmentationLayer = self.pigmentationLayer;
    copyObj.acneLayer = self.acneLayer;
    copyObj.wrinkleLayer = self.wrinkleLayer;
    copyObj.pore = [self.pore mutableCopy];
    copyObj.pouch = [self.pouch mutableCopy];
    copyObj.eyeshape = [self.eyeshape mutableCopy];
    copyObj.eyebrow = [self.eyebrow mutableCopy];
    copyObj.blackHead = [self.blackHead mutableCopy];
    copyObj.facePose = [self.facePose mutableCopy];
    copyObj.imageQuality = [self.imageQuality mutableCopy];
    copyObj.wrinkles = [self.wrinkles mutableCopy];
    copyObj.pigmentations = [self.pigmentations mutableCopy];
    copyObj.darkCircle = [self.darkCircle mutableCopy];
    copyObj.oil = [self.oil mutableCopy];
    copyObj.moisture = [self.moisture mutableCopy];
    copyObj.acnes = [self.acnes mutableCopy];
    copyObj.fatGranule = [self.fatGranule mutableCopy];
    return copyObj;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [self copyWithZone:zone];
}

+ (instancetype)modelWithJSON:(NSDictionary*)json
{
    if (!json) {
        return nil;
    }
    return [[self alloc]initWithJSON:json];
}

- (instancetype)initWithJSON:(NSDictionary*)json
{
    self = [super init];
    if (self) {
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            [self setValuesForKeysWithDictionary:json];
        }
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"pore"]) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            self.pore = [HETSkinInfoPore modelWithJSON:value];
        }
    }
    else if ([key isEqualToString:@"pouch"]) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            self.pouch = [HETSkinInfoPouch modelWithJSON:value];
        }
    }
    else if ([key isEqualToString:@"eyeshape"]) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            self.eyeshape = [HETSkinInfoEyeShape modelWithJSON:value];
        }
    }
    else if ([key isEqualToString:@"eyebrow"]) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            self.eyebrow = [HETSkinInfoEyeBrow modelWithJSON:value];
        }
    }
    else if ([key isEqualToString:@"blackHead"]) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            self.blackHead = [HETSkinInfoBlackHead modelWithJSON:value];
        }
    }
    else if ([key isEqualToString:@"facePose"]) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            self.facePose = [HETSkinInfoFacePose modelWithJSON:value];
        }
    }
    else if ([key isEqualToString:@"imageQuality"]) {
        if ([value isKindOfClass:[NSDictionary class]]) {
            self.imageQuality = [HETSkinInfoImageQuality modelWithJSON:value];
        }
    }
    else if ([key isEqualToString:@"wrinkles"]) {
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *tagList = (NSArray*)value;
            NSMutableArray *tmpArray = [NSMutableArray array];
            [tagList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                    HETSkinInfoWrinkles *aModel = [HETSkinInfoWrinkles modelWithJSON:obj];
                    if (aModel) {
                        [tmpArray addObject:aModel];
                    }
                }
            }];
            self.wrinkles = [NSArray arrayWithArray:tmpArray];
        }
    }
    else if ([key isEqualToString:@"pigmentations"]) {
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *tagList = (NSArray*)value;
            NSMutableArray *tmpArray = [NSMutableArray array];
            [tagList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                    HETSkinInfoPigmentation *aModel = [HETSkinInfoPigmentation modelWithJSON:obj];
                    if (aModel) {
                        [tmpArray addObject:aModel];
                    }
                }
            }];
            self.pigmentations = [NSArray arrayWithArray:tmpArray];
        }
    }
    else if ([key isEqualToString:@"darkCircle"]) {
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *tagList = (NSArray*)value;
            NSMutableArray *tmpArray = [NSMutableArray array];
            [tagList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                    HETSkinInfoDarkCircle *aModel = [HETSkinInfoDarkCircle modelWithJSON:obj];
                    if (aModel) {
                        [tmpArray addObject:aModel];
                    }
                }
            }];
            self.darkCircle = [NSArray arrayWithArray:tmpArray];
        }
    }
    else if ([key isEqualToString:@"oil"]) {
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *tagList = (NSArray*)value;
            NSMutableArray *tmpArray = [NSMutableArray array];
            [tagList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                    HETSkinInfoOil *aModel = [HETSkinInfoOil modelWithJSON:obj];
                    if (aModel) {
                        [tmpArray addObject:aModel];
                    }
                }
            }];
            self.oil = [NSArray arrayWithArray:tmpArray];
        }
    }
    else if ([key isEqualToString:@"moisture"]) {
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *tagList = (NSArray*)value;
            NSMutableArray *tmpArray = [NSMutableArray array];
            [tagList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                    HETSkinInfoMoisture *aModel = [HETSkinInfoMoisture modelWithJSON:obj];
                    if (aModel) {
                        [tmpArray addObject:aModel];
                    }
                }
            }];
            self.moisture = [NSArray arrayWithArray:tmpArray];
        }
    }
    else if ([key isEqualToString:@"acnes"]) {
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *tagList = (NSArray*)value;
            NSMutableArray *tmpArray = [NSMutableArray array];
            [tagList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                    HETSkinInfoAcne *aModel = [HETSkinInfoAcne modelWithJSON:obj];
                    if (aModel) {
                        [tmpArray addObject:aModel];
                    }
                }
            }];
            self.acnes = [NSArray arrayWithArray:tmpArray];
        }
    }
    else if ([key isEqualToString:@"fatGranule"]) {
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray *tagList = (NSArray*)value;
            NSMutableArray *tmpArray = [NSMutableArray array];
            [tagList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                    HETSkinInfoFatGranule *aModel = [HETSkinInfoFatGranule modelWithJSON:obj];
                    if (aModel) {
                        [tmpArray addObject:aModel];
                    }
                }
            }];
            self.fatGranule = [NSArray arrayWithArray:tmpArray];
        }
    }
    else
    {
        [super setValue:value forKey:key];
    }
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"wrinkles" : [HETSkinInfoWrinkles class],
              @"pigmentations" : [HETSkinInfoPigmentation class],
              @"darkCircle" : [HETSkinInfoDarkCircle class],
              @"oil" : [HETSkinInfoOil class],
              @"moisture" : [HETSkinInfoMoisture class],
              @"acnes" : [HETSkinInfoAcne class],
              @"fatGranule" : [HETSkinInfoFatGranule class]};
}

+ (NSDictionary *)modelContainerPropertyGenericClass
{
    return @{ @"wrinkles" : [HETSkinInfoWrinkles class],
              @"pigmentations" : [HETSkinInfoPigmentation class],
              @"darkCircle" : [HETSkinInfoDarkCircle class],
              @"oil" : [HETSkinInfoOil class],
              @"moisture" : [HETSkinInfoMoisture class],
              @"acnes" : [HETSkinInfoAcne class],
              @"fatGranule" : [HETSkinInfoFatGranule class]};
}
@end
