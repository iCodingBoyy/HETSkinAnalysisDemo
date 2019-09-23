//
//  HETSkinAnalysisAPI.h
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/17.
//  Copyright © 2019 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *HETGETValidAccessToken(void);
FOUNDATION_EXPORT NSString *HETGETValidURLSignature(NSString *key);
FOUNDATION_EXPORT BOOL HETSaveURLSignatureData(id object, NSString *key);

@interface HETSkinAnalysisAPI : NSObject

+ (NSURLSessionDataTask*)getAccessToken:(void(^)(NSString *accessToken, NSError *error))retHandler;


+ (NSURLSessionDataTask*)getQCloudCredential:(NSString*)accessToken
                                      result:(void(^)(id responseObject, NSError *error))retHandler;

+ (NSURLSessionDataTask*)getSkinAnalysisData:(NSString*)accessToken
                                    imageUrl:(NSString*)imageUrl
                                      result:(void(^)(id responseObject, NSError *error))retHandler;

+ (NSURLSessionDataTask*)getJSONApiSignature:(NSString*)accessToken
                                   bucketUrl:(NSString*)bucketUrl
                                      result:(void(^)(id responseObject, NSError *error))retHandler;
@end

