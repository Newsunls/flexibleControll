//
//  DrawerView.h
//  Drawer
//
//  Created by admin on 16/9/8.
//  Copyright © 2016年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawerView : UIView<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic) UITableView *table;
@end
