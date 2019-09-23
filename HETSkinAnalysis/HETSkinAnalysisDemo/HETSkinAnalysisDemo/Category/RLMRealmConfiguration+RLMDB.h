//
//  RLMRealmConfiguration+RLMDB.h
//  MMDataBase
//
//  Created by 远征 马 on 2019/8/5.
//  Copyright © 2019 马远征. All rights reserved.
//

#import <Realm/Realm.h>

@interface RLMRealmConfiguration (RLMDB)
+ (RLMRealmConfiguration*)remoteUserRealmConfiguration:(NSString *)user;
@end


