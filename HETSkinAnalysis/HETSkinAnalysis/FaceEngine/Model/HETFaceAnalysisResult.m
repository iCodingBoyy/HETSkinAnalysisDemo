//
//  HETVideoFrameBufferAnalysisResult.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/12.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETFaceAnalysisResult.h"

@implementation HETFaceAnalysisResult
- (instancetype)copyWithZone:(NSZone *)zone {
    HETFaceAnalysisResult *copyObj = [[[self class] allocWithZone:zone] init];
    copyObj.status = self.status;
    copyObj.distance = self.distance;
    copyObj.light = self.light;
    copyObj.faces = self.faces.mutableCopy;
    return copyObj;
}

- (NSDictionary*)params
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:@(self.status) forKey:@"cameraStatus"];
    [dictionary setObject:self.statusDesc forKey:@"statusDesc"];
    [dictionary setObject:@(self.distance) forKey:@"distance"];
    [dictionary setObject:@(self.light) forKey:@"light"];
    
    NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
    for (id<HETFaceAnalysisResultDelegate> faceInfo in self.faces) {
        NSDictionary *faceParams = [faceInfo params];
        if (faceParams) {
            [tmpArray addObject:faceParams];
        }
    }
    [dictionary setObject:tmpArray forKey:@"faces"];
    return dictionary;
}

- (NSString*)description
{
    NSDictionary *dictionary = [self params];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    if (!jsonData) {
        NSLog(@"--error--%@",error);
        return nil;
    }
    NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return result;
}

- (NSString*)printString
{
    NSMutableString *print = [[NSMutableString alloc]init];
    [print appendString:@"-----人脸检测结果-----\n"];
    [print appendFormat:@"(1) 状态：%@\n",@(self.status)];
    [print appendFormat:@"(2) 状态描述：%@\n",self.statusDesc];
    [print appendFormat:@"(3) 亮度：%@\n",@(self.light)];
    [print appendFormat:@"(4) 距离：%@\n",@(self.distance)];
    for (id<HETFaceAnalysisResultDelegate> faceInfo in self.faces) {
        NSString *string = [faceInfo logString];
        if (string) {
            [print appendString:string];
        }
    }
    [print appendString:@"-----结束-----\n"];
    return [NSString stringWithString:print];
}
@end
