//
//  Something.h
//  LanZhou2
//
//  Created by User on 16/4/14.
//  Copyright © 2016年 suntrans. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "GCDAsyncSocket.h"
@protocol SomethingDelegate <NSObject>
@optional
-(void)SixSensedataDeal:(NSData *)data;
-(void)SwitchDataDeal:(NSData *)data;
- (void)didReadSwitchAllPara:(NSData *)data;
- (void)didReadThreePhaseMeterInfo:(NSData *)data;
- (void)didReadCurrentVoltage:(NSData *)data;
@end


@interface Something : NSObject
+ (Something *)shareManager;
-(void)linkToHost;
-(void)registPhone;
-(void)readAllDataOfSixSense:(NSUInteger)SixSenseAddress;
-(void)readAllDataOfSwitch:(NSUInteger)switchAdress fromSix:(NSUInteger)sixAdress;
- (void)sswitchsetChannel:(NSUInteger) channel State:(BOOL)state sixSenseAdd:(NSUInteger)sixSenseAdd switchAdd:(NSUInteger)switchAdd;
- (void)readSwitchAllPara_sixSenseAdd:(NSUInteger)sixSenseAdd switchAdd:(NSUInteger)switchAdd;
- (void)readThreePhaseMeterAllPara_meterAdd:(UInt64)meterAdd;
@property(nonatomic,strong) GCDAsyncSocket *sockett;
@property (nonatomic,assign) id<SomethingDelegate> delegate;
@property (nonatomic) BOOL isConnected;
@end
