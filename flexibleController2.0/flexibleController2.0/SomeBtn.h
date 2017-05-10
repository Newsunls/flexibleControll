//
//  btn.h
//  Drawer
//
//  Created by admin on 16/9/8.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SomeBtn : UIImageView
@property(nonatomic) int channel;
@property(nonatomic,) BOOL state;
@property(nonatomic) int imageNum;
@property(nonatomic,assign) CGFloat myFramex;
@property(nonatomic,assign) CGFloat myFramey;
-(void)setState:(BOOL)on;
@end
