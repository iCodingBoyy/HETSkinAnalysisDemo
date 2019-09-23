//
//  HETSkinAnalysisURL.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/20.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETSkinAnalysisURL.h"

FOUNDATION_EXTERN_INLINE NSString *HETAccessTokenURLPath(void)
{
    return @"/v1/cloud/token";
}

FOUNDATION_EXTERN_INLINE NSString *HETQCloudCredentialURLPath(void)
{
    return @"/apigateway/tencentSecretApi/clifedata/getCredential";
}

FOUNDATION_EXTERN_INLINE NSString *HETSkinAnalysisURLPath(void)
{
    return @"/apigateway/beautyopen/clife-beautycamp-api-app-open/cloud/skinImage/analysis";
}

FOUNDATION_EXTERN_INLINE NSString *HETJSONApiSignatureURLPath(void)
{
    return @"/apigateway/tencentSecretApi/clifedata/getJsonApiSignatureWithBucketUrl";
}

@implementation HETSkinAnalysisURL

@end
