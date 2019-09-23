//
//  NSData+HETSkinAnalysis.h
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/8.
//  Copyright © 2019 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (HETSkinAnalysis)
// aes cfb nopadding
- (NSData*)hetAESCfbNoPaddingEncryptWithKey:(NSString *)key iv:(NSString *)iv;
- (NSData*)hetAESCfbNoPaddingDecryptWithKey:(NSString *)key iv:(NSString *)iv;

// aes cbc pkcs7padding
- (NSData*)hetAESCbcPkcf7PaddingEncryptWithKey:(NSString *)key iv:(NSString *)iv;
- (NSData*)hetAESCbcPkcf7PaddingDecryptWithKey:(NSString *)key iv:(NSString *)iv;
@end

NS_ASSUME_NONNULL_END
