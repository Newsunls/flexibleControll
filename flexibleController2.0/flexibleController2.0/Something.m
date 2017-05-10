//
//  Something.m
//  LanZhou2
//
//  Created by User on 16/4/14.
//  Copyright © 2016年 suntrans. All rights reserved.
//

#import "Something.h"

@implementation Something
@synthesize isConnected;
+ (Something *)shareManager
{
    static Something *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[self alloc] init];
    });
    return shareManager;
}
#pragma mark some methods
-(void)linkToHost
{
    self.sockett = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.sockett connectToHost:@"192.168.2.1" onPort:8000 error:nil];
}
-(void)registPhone{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 启动读数据
        
        Byte byte[] = {0XAB,0X70,0,1,0X1A,0XF6};
        //        //NSLog(@"byte:%d byte+2:%d",*byte,*(byte+2));
        byte[4] = [self getCRC16Code:byte withNumber:4 fromIndex:0]%256;
        byte[5] = [self getCRC16Code:byte withNumber:4 fromIndex:0]/256;
        
        [[Something shareManager].sockett writeData:[[NSData alloc] initWithBytes:byte length:6] withTimeout:5 tag:1];
    });
}
#pragma CRC check

- (BOOL)isDataFitCRC16:(NSData *)data
{
    uint16_t CRC_SEED = 0XFFFF;
    uint16_t CRC16Poly = 0XA001;
    uint16_t CRCReg = CRC_SEED;
    
    uint16_t length = [data length];
    Byte *byteData = (Byte *)[data bytes];
    
    for (int i = 0; i < length; i++) {
        CRCReg ^= byteData[i];
        for (int j = 0; j < 8; j++) {
            if (CRCReg & 0x0001) {
                CRCReg = (CRCReg >> 1) ^ CRC16Poly;
            } else {
                CRCReg = CRCReg >> 1;
            }
        }
    }
    if (CRCReg == 0) {
        return YES;
    } else {
        return NO;
    }
}

- (uint16_t)getCRC16Code:(Byte *)uint8Array withNumber:(uint16_t)number fromIndex:(uint16_t)index
{
    uint16_t CRC_SEED = 0XFFFF;
    uint16_t CRC16Poly = 0XA001;
    uint16_t CRCReg = CRC_SEED;
    
    for (int i = 0; i < number; i++) {
        CRCReg ^= uint8Array[i+index];
        for (int j = 0; j < 8; j++) {
            if (CRCReg & 0x0001) {
                CRCReg = (CRCReg >> 1) ^ CRC16Poly;
            } else {
                CRCReg = CRCReg >> 1;
            }
        }
    }
    return CRCReg;
}

#pragma mark socket

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"connect successed");
    [Something shareManager].isConnected = YES;
    [self.sockett readDataWithTimeout:-1 tag:0];
}
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"receive data:%@",data);
    Byte *dataByte = (Byte *)[data bytes];
    //NSLog(@"delegate : %@",self.delegate);
    if (dataByte[0]==0xab && data.length == 45) {   //第一个第六感的传感器值
        //NSLog(@"SELf.delegate:%@",self.delegate);
        if([self.delegate respondsToSelector:@selector(SixSensedataDeal:)])
        {
            //NSLog(@"respond");
            [self.delegate SixSensedataDeal:data];
        }
        else NSLog(@"not respond");
    }
    else if(dataByte[0]==0xaa && data.length == 26){ // 第一个开关的数据
        //NSLog(@"delegate : %@",self.delegate);
        if([self.delegate respondsToSelector:@selector(SwitchDataDeal:)])
        {
            //NSLog(@"respond");
            [self.delegate SwitchDataDeal:data];
        }
           //current
        if([self.delegate respondsToSelector:@selector(didReadCurrentVoltage:)])
        {
            //NSLog(@"respond");
            [self.delegate didReadCurrentVoltage:data];
        }
        }
    else if(dataByte[0]==0xfe )
    {
        if([self.delegate respondsToSelector:@selector(didReadThreePhaseMeterInfo:)])
        {
            //NSLog(@"respond");
            [self.delegate didReadThreePhaseMeterInfo:data];
        }
    }
    else if(dataByte[0]==0xaa && data.length == 28)
    {
        if([self.delegate respondsToSelector:@selector(didReadSwitchAllPara:)])
        {
            //NSLog(@"respond");
            [self.delegate didReadSwitchAllPara:data];
        }
    }
    
    [self.sockett readDataWithTimeout:-1 tag:0];
}


-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    [Something shareManager].isConnected = NO;
    NSLog(@"disconnect");
}
#pragma mark update from socket
-(void)readAllDataOfSixSense:(NSUInteger)SixSenseAddress
{
    if(![self.sockett isConnected])
    {
        [self linkToHost];
    }
    float delay = 0.1; // 0.1s延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 读开关所有的状态
        
        Byte byte[] = {0XAB,0X68,0,1,0XF0,3,1,0,0,17,0,0,0X0D,0X0A};
        byte[2]=SixSenseAddress/256;
        byte[3] = SixSenseAddress%256;
        //        //NSLog(@"byte:%d byte+2:%d",*byte,*(byte+2));
        byte[10] = [self getCRC16Code:byte+2 withNumber:6 fromIndex:2]%256;
        byte[11] = [self getCRC16Code:byte+2 withNumber:6 fromIndex:2]/256;
        [self.sockett writeData:[[NSData alloc] initWithBytes:byte length:14] withTimeout:5 tag:1];
        //NSLog(@"write data:%@",[[NSData alloc] initWithBytes:byte length:14]);
    });

}
-(void)readAllDataOfSwitch:(NSUInteger)switchAdress fromSix:(NSUInteger)sixAdress
{
    if(![self.sockett isConnected])
    {
        [self linkToHost];
    }
    float delay = 0.1; // 0.1s延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 读开关所有的状态
        
        Byte byte[] = {0XAA,0X68,0,0,0,0,3,1,0,0,7,0,0,0X0D,0X0A};
        byte[2] = sixAdress/256;
        byte[3] = sixAdress%256;
        byte[4] = switchAdress/256;
        byte[5] = switchAdress%256;

        byte[11] = [self getCRC16Code:byte withNumber:9 fromIndex:2]%256;
        byte[12] = [self getCRC16Code:byte withNumber:9 fromIndex:2]/256;
        [self.sockett writeData:[[NSData alloc] initWithBytes:byte length:15] withTimeout:5 tag:1];
        
        //NSLog(@"write data:%@",[[NSData alloc] initWithBytes:byte length:15]);
    });
}
- (void)sswitchsetChannel:(NSUInteger) channel State:(BOOL)state sixSenseAdd:(NSUInteger)sixSenseAdd switchAdd:(NSUInteger)switchAdd
{
    if(![self.sockett isConnected])
    {
        [self linkToHost];
    }
    float delay = 0.1; // 0.1s延迟
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 启动读数据
        Byte byte[] = {0XAA,0X68,0,0,0,0,6,3,0,0,0,0,0,0X0D,0X0A};
        byte[2] = sixSenseAdd/256;
        byte[3] = sixSenseAdd%256;
        byte[4] = switchAdd/256;
        byte[5] = switchAdd%256;
        
        byte[8] = channel;
        byte[10] = state;
        byte[11] = [self getCRC16Code:byte withNumber:9 fromIndex:2]%256;
        byte[12] = [self getCRC16Code:byte withNumber:9 fromIndex:2]/256;
        //        //NSLog(@"哈哈 open channel:%lu ON:%d data:%@",(unsigned long)channel,state,[[NSData alloc] initWithBytes:byte length:15]);
        [self.sockett writeData:[[NSData alloc] initWithBytes:byte length:15] withTimeout:5 tag:10];
        //NSLog(@"write data:%@",[[NSData alloc] initWithBytes:byte length:15]);
    });
}
/**
 * 读六感官地址下的某个开关配置参数
 **/
- (void)readSwitchAllPara_sixSenseAdd:(NSUInteger)sixSenseAdd switchAdd:(NSUInteger)switchAdd
{
    float delay = 0.001; // 0.1s延迟
  //  [self updateNowSwitch:aSwitch];
    // 先判断socket是否连接上 没连接上则重新建立连接
    if(![self.sockett isConnected])
    {
        [self linkToHost];
    }
     delay = 0.1; // 0.1s延迟
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 读开关所有的状态
        Byte byte[] = {0XAA,0X68,0,0,0,0,3,2,0,0,8,0,0,0X0D,0X0A};
        byte[2] = sixSenseAdd/256;
        byte[3] = sixSenseAdd%256;
        byte[4] = switchAdd/256;
        byte[5] = switchAdd%256;
        
        byte[11] = [self getCRC16Code:byte withNumber:9 fromIndex:2]%256;
        byte[12] = [self getCRC16Code:byte withNumber:9 fromIndex:2]/256;
        [self.sockett writeData:[[NSData alloc] initWithBytes:byte length:15] withTimeout:5 tag:1];
        //NSLog(@"write data:%@",[[NSData alloc] initWithBytes:byte length:15]);
    });
}
/**
 * 发送命令读取三相电表的所有参数
 **/
- (void)readThreePhaseMeterAllPara_meterAdd:(UInt64)meterAdd
{
    float delay = 0.001; // 0.1s延迟
    // 先判断socket是否连接上 没连接上则重新建立连接
    if(![self.sockett isConnected])
    {
        [self linkToHost];
    }
    delay = 0.1; // 0.1s延迟
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 读开关所有的状态
        Byte byte[] = {0XFE,0X68,0,0,0,0,0,0,0X68,0X1F,0,0X00,0X16};
        byte[2]     = meterAdd%256; //byte[2] += byte[2]/10*6;
        byte[3]     = meterAdd>>8%256; //byte[3] += byte[3]/10*6;
        byte[4]     = meterAdd>>16%256; //byte[4] += byte[4]/10*6;
        byte[5]     = meterAdd>>24%256; //byte[5] += byte[5]/10*6;
        byte[6]     = meterAdd>>32%256; //byte[6] += byte[6]/10*6;
        byte[7]     = meterAdd>>40%256; //byte[7] += byte[7]/10*6;
        byte[11]    = (byte[1]+byte[2]+byte[3]+byte[4]+byte[5]+byte[6]+byte[7]+byte[8]+byte[9]+byte[10]); // 校验码
        [self.sockett writeData:[[NSData alloc] initWithBytes:byte length:13] withTimeout:5 tag:1];
        NSLog(@"write data :%@",[[NSData alloc] initWithBytes:byte length:13]);
        
    });
}
@end
