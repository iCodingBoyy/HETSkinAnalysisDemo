//
//  RLMRealm+RLMDB.m
//  MMDataBase
//
//  Created by 远征 马 on 2019/8/5.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "RLMRealm+RLMDB.h"
#import "RLMRealmConfiguration+RLMDB.h"

@implementation RLMRealm (RLMDB)
+ (void)setDefaultRealmWithUser:(NSString*)userId
{
    if (!userId) {
        return;
    }
    RLMRealmConfiguration *config = [RLMRealmConfiguration remoteUserRealmConfiguration:userId];
    config.schemaVersion = 0;
    config.migrationBlock = ^(RLMMigration * _Nonnull migration, uint64_t oldSchemaVersion) {
        NSLog(@"-appUserDataBaseMigration--oldSchemaVersion----%@",@(oldSchemaVersion));
        // 我们目前还未执行过迁移，因此 oldSchemaVersion == 0
        if (oldSchemaVersion < 1) {
            // 没有什么要做的！
            // Realm 会自行检测新增和被移除的属性
            // 然后会自动更新磁盘上的架构
        }
    };
    config.shouldCompactOnLaunch = ^BOOL(NSUInteger totalBytes, NSUInteger usedBytes) {
        // totalBytes refers to the size of the file on disk in bytes (data + free space)
        // usedBytes refers to the number of bytes used by data in the file
        
        // Compact if the file is over 100MB in size and less than 50% 'used'
        NSUInteger oneHundredMB = 100 * 1024 * 1024;
        return (totalBytes > oneHundredMB) && ((double)usedBytes / totalBytes) < 0.5;
    };
    [RLMRealmConfiguration setDefaultConfiguration:config];
    [RLMRealm defaultRealm];
}

+ (BOOL)rlmTransactionWithBlock:(void(^)(RLMRealm *defaultRealm))block
{
    NSError *error;
    RLMRealm *realm = [RLMRealm defaultRealm];
    BOOL ret = [realm transactionWithBlock:^{
        if (block) {
            block(realm);
        }
    } error:&error];
    if (ret) {
        NSLog(@"--保存成功--");
    }
    else
    {
        NSLog(@"--保存失败--%@",error);
    }
    return ret;
}
@end
