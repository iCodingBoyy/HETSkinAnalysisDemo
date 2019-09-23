//
//  NSString+HETSkinAnalysis.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/8.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "NSString+HETSkinAnalysis.h"
#import "NSData+HETSkinAnalysis.h"
#import <CommonCrypto/CommonDigest.h>

#define IV  @"\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"
#define KEY @"41e99b3bcef74dae88cc2e6a94adfa49"


@implementation NSString (HETSkinAnalysis)

+ (NSString*)getUUIDString
{
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    NSString *result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    result = [result stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return [result lowercaseString];
}

+ (NSString *)hetEncryptString:(NSString *)string
{
    if (!string) {
        return nil;
    }
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *result = [data hetAESCfbNoPaddingEncryptWithKey:KEY iv:IV];
    //转换为2进制字符串
    if(result && result.length > 0)
    {
        Byte *datas = (Byte *)[result bytes];
        NSMutableString *outPut = [NSMutableString stringWithCapacity:result.length];
        for(int i = 0 ; i < result.length ; i++)
        {
            [outPut appendFormat:@"%02x",datas[i]];
        }
        return outPut;
    }
    return nil;
}

+ (NSString *)hetDecryptString:(NSString *)string
{
    if (!string) {
        return nil;
    }
    NSMutableData *data = [NSMutableData dataWithCapacity:string.length/2.0];
    unsigned char whole_bytes;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for(i = 0 ; i < [string length]/2 ; i++)
    {
        byte_chars[0] = [string characterAtIndex:i * 2];
        byte_chars[1] = [string characterAtIndex:i * 2 + 1];
        whole_bytes = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_bytes length:1];
    }
    NSData *result = [data hetAESCfbNoPaddingDecryptWithKey:KEY iv:IV];
    if(result && result.length > 0)
    {
        return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    }
    return nil;
}



- (NSString *)md5String
{
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02X", digest[i]];
    }
    return [result lowercaseString];
}
@end
