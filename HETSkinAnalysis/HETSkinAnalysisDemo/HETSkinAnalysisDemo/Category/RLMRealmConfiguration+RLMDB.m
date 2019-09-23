//
//  RLMRealmConfiguration+RLMDB.m
//  MMDataBase
//
//  Created by 远征 马 on 2019/8/5.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "RLMRealmConfiguration+RLMDB.h"
#import "HETSkinAnalysisConfig.h"

static NSString *const rlm_remoteUserRealmFileName = @"demo.remoteUser.realm";
RLMRealmConfiguration *rlm_remoteUserConfiguration;

@implementation RLMRealmConfiguration (RLMDB)
+ (RLMRealmConfiguration *)remoteUserConfiguration
{
    RLMRealmConfiguration *configuration;
    @synchronized(rlm_remoteUserRealmFileName) {
        if (!rlm_remoteUserConfiguration) {
            rlm_remoteUserConfiguration = [RLMRealmConfiguration defaultConfiguration];
        }
        configuration = rlm_remoteUserConfiguration;
    }
    return configuration;
}

+ (NSArray*)getObjectClassForRemoteUser
{
    return @[[HETSkinAnalysisConfig class]];
}

+ (RLMRealmConfiguration*)remoteUserRealmConfiguration:(NSString *)user
{
    if (!user) {
        return nil;
    }
    RLMRealmConfiguration *config = [RLMRealmConfiguration remoteUserConfiguration];
    NSArray *libraryPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *dataBasePath = [libraryPath objectAtIndex:0];
    NSString *filePath = [dataBasePath stringByAppendingPathComponent:user];
    config.fileURL = [[NSURL URLWithString:filePath]URLByAppendingPathExtension:@"realm"];
    config.objectClasses = [self getObjectClassForRemoteUser];
    return config;
}
@end
