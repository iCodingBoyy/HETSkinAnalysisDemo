//
//  NSData+HETSkinAnalysis.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/8.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "NSData+HETSkinAnalysis.h"
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (HETSkinAnalysis)

- (NSData *)fullData:(NSData *)originData mode:(NSUInteger)mode {
    NSMutableData *tmpData = [[NSMutableData alloc] initWithData:originData];
    // 确定要补全的个数
    NSUInteger shouldLength = mode * ((tmpData.length / mode) + 1);
    NSUInteger diffLength = shouldLength - tmpData.length;
    uint8_t *bytes = malloc(sizeof(*bytes) * diffLength);
    for (NSUInteger i = 0; i < diffLength; i++) {
        // 补全缺失的部分
        bytes[i] = diffLength;
    }
    [tmpData appendBytes:bytes length:diffLength];
    return tmpData;
}

#pragma mark - aes cfb nopadding

- (NSData*)AESCfbNopadding:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv
{
    NSData *ivData = [iv dataUsingEncoding:NSUTF8StringEncoding] ;
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    CCCryptorRef cryptor = NULL;
    CCCryptorStatus cryptStatus = CCCryptorCreateWithMode(operation,
                                                     kCCModeCFB,
                                                     kCCAlgorithmAES,
                                                     ccNoPadding,
                                                     [ivData bytes],
                                                     [keyData bytes],
                                                     keyData.length,
                                                     NULL,
                                                     0,
                                                     0,
                                                     0,
                                                     &cryptor);
    if (cryptStatus == kCCSuccess)
    {
        NSUInteger inputLength = self.length;

        size_t outLength = 0;
        size_t bufferlen = CCCryptorGetOutputLength(cryptor,inputLength,true);
        char *outData = malloc(bufferlen);
        memset(outData, 0, bufferlen);

        cryptStatus =  CCCryptorUpdate(cryptor, self.bytes, inputLength, outData, bufferlen, &outLength);
        if (cryptStatus != kCCSuccess) {
            CCCryptorRelease(cryptor);
            free(outData);
            return nil;
        }
        NSData *data = [NSData dataWithBytes:outData length:outLength];
        CCCryptorRelease(cryptor);
        free(outData);
        return data;
    }
    CCCryptorRelease(cryptor);
    return nil;
}

// aes cfb nopadding
- (NSData*)hetAESCfbNoPaddingEncryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AESCfbNopadding:kCCEncrypt key:key iv:iv];
}

- (NSData*)hetAESCfbNoPaddingDecryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AESCfbNopadding:kCCDecrypt key:key iv:iv];
}

#pragma mark - aes cbc pkcf7padding

- (NSData*)AESCbcPkcf7Padding:(CCOperation)operation key:(NSString *)key iv:(NSString *)iv
{
    const char *keyPtr = [key cStringUsingEncoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          key.length,
                                          ivPtr,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        return resultData;
        
    }
    free(buffer);
    return nil;
}

// aes cbc pkcs7padding
- (NSData*)hetAESCbcPkcf7PaddingEncryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AESCbcPkcf7Padding:kCCEncrypt key:key iv:iv];
}

- (NSData*)hetAESCbcPkcf7PaddingDecryptWithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AESCbcPkcf7Padding:kCCDecrypt key:key iv:iv];
}

@end
