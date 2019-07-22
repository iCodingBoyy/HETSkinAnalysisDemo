//
//  HETDeviceControlBusiness.h
//  HETOpenSDK
//
//  Created by mr.cao on 15/8/13.
//  Copyright (c) 2015年 mr.cao. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HETDevice.h"

typedef void(^SuccessBlock)(id responseObject);
typedef void(^FailureBlock)( NSError *error);
typedef void(^DataBlock)(id responseObject);


@interface HETDeviceControlBusiness : NSObject
//当前是否小循环
@property (nonatomic,readonly ) BOOL        isLittleLoop;
//设备ID号
@property (nonatomic,readonly ) NSString    *deviceId;

//设置小循环数据发送最大次数，默认发送10次
@property (nonatomic, assign  ) NSUInteger  packetSendTimes;

//设置小循环数据包重发的间隔时间，默认2秒发送一次
@property (nonatomic, assign  )NSTimeInterval  packetSendTimeInterval;


//运行数据网络请求失败的回调，里面包含设备不在线(UserInfo={msg=设备不在线, code=100022006})
@property (nonatomic,copy     )FailureBlock  rundataFailBlock;

//控制数据网络请求失败的回调
@property (nonatomic,copy     )FailureBlock  cfgdataFailBlock;

//故障数据网络请求失败的回调
@property (nonatomic,copy     )FailureBlock  errordataFailBlock;

@property (nonatomic ,readonly,assign ) UInt16  packetNum;//小循环的报文号

/**
 *
 *
 *  @param device                设备的对象
 *  @param bsupport              是否需要支持小循环，默认为NO，如不需支持小循环，设置为NO
 *  @param deviceControlBusiness 设备控制业务类
 *  @param runDataBlock          设备运行数据block回调
 *  @param cfgDataBlock          设备配置数据block回调
 *  @param errorDataBlock        设备故障数据block回调
 */
- (instancetype)initWithHetDeviceModel:(HETDevice *)device
                  isSupportLittleLoop:(BOOL)bsupport
                        deviceRunData:(void(^)(id responseObject))runDataBlock
                        deviceCfgData:(void(^)(id responseObject))cfgDataBlock
                      deviceErrorData:(void(^)(id responseObject))errorDataBlock;



/**
 *  设备控制
 *
 *  @param jsonString   设备控制的json字符串
 *  @param successBlock 控制成功的回调
 *  @param failureBlock 控制失败的回调
 */
- (void)deviceControlRequestWithJson:(NSString *)jsonString withSuccessBlock:(void(^)(id responseObject))successBlock withFailBlock:(void(^)( NSError *error))failureBlock;



//启动服务
- (void)start;


//停止服务
- (void)stop;



@end





