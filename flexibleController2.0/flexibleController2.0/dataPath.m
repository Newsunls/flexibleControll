//
//  dataPath.m
//  flexibleControl
//
//  Created by admin on 16/8/20.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "dataPath.h"

@implementation dataPath
+ (NSString *)dataFilePathForRect
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [path stringByAppendingPathComponent:@"rect.plist"];
}
+ (NSString *)dataFilePathForVoiceState
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [path stringByAppendingPathComponent:@"voiceState.plist"];
}
@end
