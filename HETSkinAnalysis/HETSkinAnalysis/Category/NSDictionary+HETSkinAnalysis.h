//
//  NSDictionary+HETSkinAnalysis.h
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/17.
//  Copyright © 2019 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 从string获取非`nil`字符串，如果string为`nil`则返回`@""`
 
 @param string 输入字符串
 @return 非`nil`字符串
 */
FOUNDATION_EXPORT NSString *HETSafeNonNilString(NSString *string);

/**
 查询目标字符串
 @warning 如果object是NSDictionary类型，并且key对应的value为NSString类型则返回value，否则返回nil
 @param object 输入对象，这里应该是NSDictionary*类型
 @param key 要查询的key
 @return NSString*对象
 */
FOUNDATION_EXPORT NSString *HETSafeStringForKeyInDict(id object , NSString *key);

/**
 获取目标NSDictionary*对象
 @warning 如果object是NSDictionary*类型，并且key对应的value是NSDictionary*类型，则返回value，否则返回nil
 @param object 输入对象，这里应该是NSDictionary*类型
 @param key 要查询的key
 @return NSDictionary*对象
 */
FOUNDATION_EXPORT NSDictionary *HETSafeDictionaryForKeyInDict(id object, NSString *key);

/**
 查询key对应的NSNumber值
 
 @warning 如果key对应的value是NSNumber类，直接返回，如果为NSString类，则转为NSNumber类
 @param object 输入对象，应该是NSDiction*对象
 @param key 查询key
 @return NSNumber*对象
 */
FOUNDATION_EXPORT NSNumber *HETSafeNumberForKeyInDict(id object , NSString *key);

/**
 查询Integer数值
 
 @param object 输入对象，这里应该是NSDictionary*类型
 @param key 要查询的key
 @return Integer数值
 */
FOUNDATION_EXPORT NSInteger HETSafeIntegerForKeyInDict(id object , NSString *key);

/**
 查询目标数组
 
 @warning 如果object是NSDictionary*类型，并且key对应的value是NSArray*类型，则返回value，否则返回nil
 @param object 输入对象
 @param key 查询key
 @return NSArray*对象
 */
FOUNDATION_EXPORT NSArray *HETSafeArrayForKeyInDict(id object , NSString *key);


NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (HETSkinAnalysis)

@end

@interface NSMutableDictionary (HETSkinAnalysis)
- (void)setSafeObject:(id)anObject forKey:(id<NSCopying>)aKey;
-  (NSString*)sortedParamsString;
@end

NS_ASSUME_NONNULL_END
