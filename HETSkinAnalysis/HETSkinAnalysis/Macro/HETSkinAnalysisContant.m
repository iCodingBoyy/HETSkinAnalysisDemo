//
//  HETSkinAnalysisContant.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/6/28.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETSkinAnalysisContant.h"
#import "HETSkinAnalysisURL.h"
#import "HETSkinAnalysisAPI.h"
#import "NSString+HETSkinAnalysis.h"
#import "NSDictionary+HETSkinAnalysis.h"

NSString *HETSkinAnalysisPacketURL(NSString *encryptedURL,NSString *sign)
{
    if (!encryptedURL || !sign) {
        return nil;
    }
    NSString *decryptedURL = nil;
    if ([encryptedURL containsString:@"?"])
    {
        decryptedURL = [NSString stringWithFormat:@"%@&%@",encryptedURL,[sign stringByReplacingOccurrencesOfString:@"?" withString:@""]];
    }
    else
    {
        decryptedURL = [NSString stringWithFormat:@"%@%@",encryptedURL,sign];
    }
    return decryptedURL;
}

void HETSkinAnalysisAsyncGetAndPacketURL(NSString *accessToken,NSString *encryptedURL, HETURLDecryptResultBlock resultBlock)
{
    if (!accessToken || !encryptedURL) {
        if (resultBlock) {
            resultBlock(nil);
        }
        return;
    }
    NSString *key = [encryptedURL md5String];
    [HETSkinAnalysisAPI getJSONApiSignature:accessToken bucketUrl:encryptedURL result:^(id responseObject, NSError *error) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            HETSaveURLSignatureData(responseObject,key);
            NSString *signature = HETSafeStringForKeyInDict(responseObject, @"sign");
            NSString *decryptedURL = HETSkinAnalysisPacketURL(encryptedURL, signature);
            if (resultBlock) {
                resultBlock(decryptedURL);
            }
        }
        else
        {
            if (resultBlock) {
                resultBlock(nil);
            }
        }
    }];
}



FOUNDATION_EXTERN_INLINE void HETSkinAnalysisDecryptURL(NSString *encryptedURL,HETURLDecryptResultBlock resultBlock)
{
    if (!encryptedURL) {
        if (resultBlock) {
            resultBlock(nil);
        }
        return;
    }
    // 判断是否有有效的缓存
    NSString *accessToken = HETGETValidAccessToken();
    if (accessToken) {
        // 查询缓存的sign是否可用
        NSString *key = [encryptedURL md5String];
        NSString *sign = HETGETValidURLSignature(key);
        if (sign) {
            NSString *decryptedURL = HETSkinAnalysisPacketURL(encryptedURL, sign);
            if (resultBlock) {
                resultBlock(decryptedURL);
            }
            return;
        }
        HETSkinAnalysisAsyncGetAndPacketURL(accessToken, encryptedURL, resultBlock);
        return;
    }
    [HETSkinAnalysisAPI getAccessToken:^(NSString *accessToken, NSError *error) {
        if (accessToken) {
            // 查询缓存的sign是否可用
            // 查询缓存的sign是否可用
            NSString *key = [encryptedURL md5String];
            NSString *sign = HETGETValidURLSignature(key);
            if (sign) {
                NSString *decryptedURL = HETSkinAnalysisPacketURL(encryptedURL, sign);
                if (resultBlock) {
                    resultBlock(decryptedURL);
                }
                return;
            }
            HETSkinAnalysisAsyncGetAndPacketURL(accessToken, encryptedURL, resultBlock);
        }
        else
        {
            if (resultBlock) {
                resultBlock(nil);
            }
        }
    }];
    
}

@implementation HETSkinAnalysisContant

@end
