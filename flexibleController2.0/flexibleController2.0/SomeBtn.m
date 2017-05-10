//
//  btn.m
//  Drawer
//
//  Created by admin on 16/9/8.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "SomeBtn.h"

@implementation SomeBtn

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
@synthesize imageNum,channel,state,myFramex,myFramey;
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    myFramex = frame.origin.x;
    myFramey = frame.origin.y;
    return self;
}
-(void)setState:(BOOL)on
{
    if (on) {
        state = on;
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d_on",imageNum]];
    }
    else
    {
        state = on;
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d_off",imageNum]];
    }
    
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{   
    [aCoder encodeBool:state forKey:@"state"];
    [aCoder encodeFloat:myFramex forKey:@"myframex"];
    [aCoder encodeFloat:myFramey forKey:@"myframey"];
    [aCoder encodeInt:channel forKey:@"channel"];
    [aCoder encodeInt:imageNum forKey:@"imageNum"];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        state = [aDecoder decodeBoolForKey:@"state"];
        myFramey = [aDecoder decodeFloatForKey:@"myframey"];
        myFramex = [aDecoder decodeFloatForKey:@"myframex"];
        channel = [aDecoder decodeIntForKey:@"channel"];
        imageNum = [aDecoder decodeIntForKey:@"imageNum"];
    }
    return self;
}
@end
