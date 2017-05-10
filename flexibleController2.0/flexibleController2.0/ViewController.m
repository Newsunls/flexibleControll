//
//  ViewController.m
//  flexibleControl
//
//  Created by admin on 16/8/20.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "ViewController.h"
#import "dataPath.h"
#import "DrawerView.h"
#import "SomeBtn.h"
#import "Something.h"
@interface ViewController ()<UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,SomethingDelegate>
#define btnSize 30
#define SwitchONColor [UIColor colorWithRed:255.0/255 green:206.0/255  blue:77.0/255 alpha:0.8]
#define SwitchOffColor [UIColor blackColor]
#define drawerWidth 100
{
    UIImageView *backImage;
    DrawerView *drawerView;
    NSArray *thingsArray;
    NSMutableArray *channelArray;
    UIPanGestureRecognizer *panpanpan;
    UISwitch *switchButton;
    UILabel *infoLabel;//用来长按显示出来的label
}
@property(nonatomic,strong)     NSMutableArray *stateArray; //状态数组
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    backImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 65, self.view.bounds.size.width, self.view.bounds.size.height-65)];
    NSData *data = [[NSUserDefaults standardUserDefaults]valueForKey:@"backImage"];
    if (data == nil) {
        backImage.image = [UIImage imageNamed:@"房间.jpg"];
    }
    else backImage.image = [UIImage imageWithData: data];
    [self.view addSubview:backImage];
    
    drawerView = [[DrawerView alloc]initWithFrame:CGRectMake(-drawerWidth, 0, drawerWidth, self.view.bounds.size.height)];
    drawerView.backgroundColor = [UIColor colorWithRed:149.0/255 green:206.0/255 blue:253.0/255 alpha:1];
    drawerView.table.delegate = self;
    
    [self.view addSubview:drawerView];
    
    //初始化所有开关的位置
    _stateArray = [NSMutableArray arrayWithContentsOfFile:[dataPath dataFilePathForRect]];
    if (_stateArray == nil || _stateArray.count!=11) {
        _stateArray = [NSMutableArray arrayWithCapacity:11];
        for (int i = 0; i <11; i++) {
            _stateArray[i] = @"0";
           
        }
        [_stateArray writeToFile:[dataPath dataFilePathForRect] atomically:YES];
        
    }
    channelArray = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10", nil];
    
    //socket的建立
    [Something shareManager].delegate = self;
    [[Something shareManager] linkToHost];
    
    //添加所有的按钮
    [self readTheButtonWithGesture:NO];
    
    //添加一个开启移动和锁定移动的开关
    switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-60, 30, 20, 10)];
    [switchButton addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
    switchButton.onTintColor = [UIColor whiteColor];
    [switchButton setOn:NO];
    [self.view addSubview: switchButton];
    //添加一个重新排列的按钮
    UIButton *clearBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-180, 30, 100, 30)];
    [clearBtn addTarget:self action:@selector(rearrange:) forControlEvents:UIControlEventTouchUpInside];
    [clearBtn setTitle:@"收起按钮" forState:UIControlStateNormal];
    clearBtn.backgroundColor = [UIColor whiteColor];
    [clearBtn setTitleColor:[UIColor colorWithRed:4.0/255 green:180.0/255 blue:224.0/255 alpha:0.8] forState:UIControlStateNormal];
    
    clearBtn.titleLabel.adjustsFontSizeToFitWidth =YES;
    clearBtn.layer.cornerRadius = 10;
    clearBtn.layer.masksToBounds = YES;
    [self.view addSubview:clearBtn];
    //添加一个用来更换背景图片的按钮
    UIButton *changeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-270, 30, 80, 30)];
    [changeBtn setTitle:@"换图" forState:UIControlStateNormal];
    [changeBtn addTarget:self action:@selector(ChangeImage) forControlEvents:UIControlEventTouchUpInside];
    changeBtn.backgroundColor = [UIColor whiteColor];
    [changeBtn setTitleColor:[UIColor colorWithRed:4.0/255 green:180.0/255 blue:224.0/255 alpha:0.8] forState:UIControlStateNormal];
    changeBtn.layer.cornerRadius = 10;
    changeBtn.layer.masksToBounds = YES;
    changeBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:changeBtn];
    
    UIButton *readData = [[UIButton alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-360, 30, 80, 30)];
    [readData setTitle:@"同步数据" forState:UIControlStateNormal];
    [readData addTarget:self action:@selector(readAllData) forControlEvents:UIControlEventTouchUpInside];
    readData.backgroundColor = [UIColor whiteColor];
    [readData setTitleColor:[UIColor colorWithRed:4.0/255 green:180.0/255 blue:224.0/255 alpha:0.8] forState:UIControlStateNormal];
    readData.layer.cornerRadius = 10;
    readData.layer.masksToBounds = YES;
    readData.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:readData];
    //添加左右滑动的手势
    UISwipeGestureRecognizer *swipright = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe:)];
    swipright.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipright];
    
    UISwipeGestureRecognizer *swipleft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe:)];
    swipleft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipleft];
    
    self.view.backgroundColor = [UIColor colorWithRed:4.0/255 green:180.0/255 blue:224.0/255 alpha:0.8];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//重新排列所有的开关在屏幕的左上方
-(void)rearrange:(id)sender
{
    for (int i =1 ; i<=10; i++)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%d",i]];
        
    }
    channelArray = [NSMutableArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10", nil];
    [self removeAllButton];
}
-(void)removeAllButton
{
    for (id obj in self.view.subviews)
    {
        if ([obj isKindOfClass:[SomeBtn class]]) {
            [obj removeFromSuperview];
        }
    }
}
//处理触摸某个开关的事件
-(void)touchedSomething:(UITapGestureRecognizer *)sender
{
    SomeBtn *tapedImage = (SomeBtn *)sender.view;
    NSLog(@"%d",tapedImage.channel);
    if (tapedImage.state ) {
        
        [tapedImage setState:NO];
        
        [[Something shareManager] sswitchsetChannel:tapedImage.channel State:NO sixSenseAdd:0x18 switchAdd:2];
        [self saveTheButton:tapedImage key:tapedImage.channel];
        [self saveChannel:tapedImage.channel state:NO];
    }
    else
    {
        
        [tapedImage setState:YES];
        [[Something shareManager] sswitchsetChannel:tapedImage.channel State:YES sixSenseAdd:0x18 switchAdd:2];
        [self saveTheButton:tapedImage key:tapedImage.channel];
        [self saveChannel:tapedImage.channel state:YES];
    }
    
}
-(void)readAllData
{
    [[Something shareManager]readAllDataOfSwitch:2 fromSix:0x18];
}
//开启或者关闭锁定开关按钮的处理
-(void)changeSwitch:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    
//    
//    for (int i = 0; i<10; i++) {
//        UIButton *btn1 = (UIButton *)[self.view viewWithTag:100+i];
//        //按钮添加拖动手势
//        UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(draging:)];
//        drag.minimumNumberOfTouches =1;
//        drag.maximumNumberOfTouches =1;
//        if (switchButton.on) {
//            [btn1 addGestureRecognizer:drag];
//        }
//        else {
//            CGRect re =CGRectMake([_rectArray[i*4] floatValue]-btnSize/2, [_rectArray[i*4+1] floatValue]-btnSize/2, btnSize, btnSize);
//            NSLog(@"rect is : %f , %f",re.origin.x,re.origin.y);
//
//            btn1.frame = re;
//        };
//        
//    }
    [self removeAllButton];
    if (switchButton.on) {
        [self readTheButtonWithGesture:YES];
    }else [self readTheButtonWithGesture:NO];
    
}

//拖动时候的处理
-(void)draging:(UIPanGestureRecognizer *)paramSender
{
    if (paramSender.state != UIGestureRecognizerStateEnded && paramSender.state != UIGestureRecognizerStateFailed){
        //通过使用 locationInView 这个方法,来获取到手势的坐标
        CGPoint location = [paramSender locationInView:paramSender.view.superview];
        paramSender.view.center = location;
        UIButton   *la = (UIButton *)paramSender.view;
        UIImageView *ima = (UIImageView *)[self.view viewWithTag:la.tag+100];
        ima.center = location;
        [self.view bringSubviewToFront:ima];
        [self.view bringSubviewToFront:la];
    }
    else
    {
        SomeBtn *btn = (SomeBtn *)paramSender.view;
        btn.myFramex = btn.frame.origin.x ;
        btn.myFramey = btn.frame.origin.y;
        if(btn.frame.origin.x < drawerView.frame.origin.x + drawerWidth-40)
        {
            [self removeTheButton:btn];
            return;
        }
        [self saveTheButton:btn key:btn.channel];
        
    }
}
-(void)longPressed:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan)
        
    {
        CGPoint location = gestureRecognizer.view.frame.origin;//[gestureRecognizer locationInView:gestureRecognizer.view.superview];
        if (location.y<100) {
            infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(location.x-20, location.y+30, 80, 30)];
            
        }
        else
        {
            infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(location.x-20, location.y-30, 80, 30)];
        }
        SomeBtn *button = (SomeBtn *)gestureRecognizer.view;
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.text = [NSString stringWithFormat:@"第%d通道",button.channel];
        infoLabel.backgroundColor = [UIColor whiteColor];
        infoLabel.layer.cornerRadius = 9;
        infoLabel.layer.masksToBounds =YES;
        [self.view addSubview:infoLabel];
    }
    
    else if(gestureRecognizer.state == UIGestureRecognizerStateEnded)
        
    {
        [infoLabel removeFromSuperview];
    }
}
//处理左右滑动
-(void)swipe:(UISwipeGestureRecognizer *)swip
{
    if (swip.direction == UISwipeGestureRecognizerDirectionRight) {
        [self drawHide:NO];
        NSLog(@"right");
        
    }
    else
        //        if(swip.direction == UISwipeGestureRecognizerDirectionLeft)
    {
//        [self readTheButton];
        [self drawHide:YES];
        NSLog(@"left");
    }
}
-(void)drawHide:(BOOL)hide
{
    if (!hide) {
        //        [UIView animateWithDuration:0.6 animations:^(void){
        //            drawerView.frame = CGRectMake(0, 0, drawerWidth, self.view.frame.size.height);
        //            [self.view bringSubviewToFront:drawerView];
        //        }];
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:3 options:UIViewAnimationOptionLayoutSubviews animations:^(void){
            drawerView.frame = CGRectMake(0, 0, drawerWidth, self.view.frame.size.height);
            [self.view bringSubviewToFront:drawerView];
            drawerView.alpha = 1;
        }completion:nil];
    }
    else
    {
        //        [UIView animateWithDuration:0.6 animations:^(void){
        //            drawerView.frame = CGRectMake(-drawerWidth, 0, drawerWidth, self.view.frame.size.height);
        //        }];
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:3 options:UIViewAnimationOptionLayoutSubviews animations:^(void){
            drawerView.frame = CGRectMake(-drawerWidth, 0, drawerWidth, self.view.frame.size.height);
            drawerView.alpha = 0;
        }completion:nil];
    }
}
//闪光的动画
-(CABasicAnimation *) AlphaLight:(float)time
{
    CABasicAnimation *animation =[CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:0.0f];//这是透明度。
    animation.autoreverses = YES;
    animation.duration = time;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    return animation;
}
#pragma mark 背景图片的处理
-(void)ChangeImage
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"图标选取" message:@"修改开关图标" preferredStyle:UIAlertControllerStyleActionSheet];
    //    [alertController addAction:[UIAlertAction actionWithTitle:@"模板" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    //      //  [self performSegueWithIdentifier:showSwitchIconDetailIdentifier sender:self];
    //    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openCamera];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"图库" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openPics];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"使用默认图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        backImage.image = [UIImage imageNamed:@"房间.jpg"];
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
    
   
    
}
- (void)openCamera {
    // UIImagePickerControllerCameraDeviceRear 后置摄像头
    // UIImagePickerControllerCameraDeviceFront 前置摄像头
    BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
    if (!isCamera) {
        [self showAlert:@"相机不可用！"];
        return ;
    }
    // 进入camera模式
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }else{
        [self showAlert:@"无法打开相机，请确认相机正常后重试！"];
    }
    // 编辑模式
    imagePicker.allowsEditing = YES;
    [self  presentViewController:imagePicker animated:YES completion:NULL];
}
- (void)openPics {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    [self  presentViewController:imagePicker animated:YES completion:NULL];
}
-(void)showAlert:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"提  示！"
                          message:msg
                          delegate:self
                          cancelButtonTitle:@"确定"
                          otherButtonTitles: nil];
    [alert show];
}
- ( void )imagePickerController:( UIImagePickerController *)picker didFinishPickingMediaWithInfo:( NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    
    backImage.image = image;
    NSData *imagedata = UIImagePNGRepresentation(backImage.image);
    [[NSUserDefaults standardUserDefaults] setObject:imagedata forKey:@"backImage"];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
- (UIImage *)scaleImageForSelf:(UIImage *)oldImage

{
    UIImage *resultImage = [[UIImage alloc]init];
    
//    CGSize size;
//    
//    size.width = backImage.frame.size.width ;
//    
//    size.height = (backImage.frame.size.width * image.size.height) /image.size.width ;
//    
 
    
    
    
    CGFloat srcRatio = oldImage.size.height/oldImage.size.width;
    
    CGFloat desRatio = backImage.frame.size.height/backImage.frame.size.width;
    
    
    
    CGRect rect;
    
    if(srcRatio > desRatio){ //截上下，宽一致
        
        CGFloat ratio = oldImage.size.width/backImage.frame.size.width;//缩放比
        
        rect.size.height = backImage.frame.size.height * ratio ;
        
        rect.size.width = oldImage.size.width;
        
        rect.origin.x = 0;
        
        rect.origin.y = (oldImage.size.height - backImage.frame.size.height)/2.0;
        
        resultImage = [self getSubImage:rect image:oldImage];
        
    }else if (srcRatio < desRatio)
        
        //截左右，高一致
    {
        
        CGFloat ratio = oldImage.size.height/backImage.frame.size.height;
        
        rect.size.width = backImage.frame.size.width * ratio;
        
        rect.size.height = oldImage.size.height ;
        
        rect.origin.x =oldImage.size.width - backImage.frame.size.width/2.0;
        
        rect.origin.y =  0;
        
        
        
        resultImage = [self getSubImage:rect image:oldImage];
        
    }else
        
    {
        
        resultImage = oldImage;//得到的图片的长宽比与iamgeView的长宽比一致，不用裁剪
        
    }
    
    return resultImage;
}
-(UIImage*)getSubImage:(CGRect)rect image:(UIImage *)oldimage
{

    CGImageRef subImageRef = CGImageCreateWithImageInRect(oldimage.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
}

//
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld",indexPath.row);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //判断是否连上了服务器
    if (![Something shareManager].isConnected) {
        [[Something shareManager] linkToHost];
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"警告" message:@"没连接网络" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertView animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertView dismissViewControllerAnimated:YES completion:nil];
            
        });
        return;
    }
    //判断有无可用的通道
    if (channelArray.count == 0) {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"警告" message:@"已经没有可用的通道" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertView animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertView dismissViewControllerAnimated:YES completion:nil];
            
        });
        return;
    }
    
    if (!switchButton.on) {
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"警告" message:@"未打开编辑模式，请点击右上角开关" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertView animated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [alertView dismissViewControllerAnimated:YES completion:nil];
            
        });
        return;
    }
    
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"确定添加电器?" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
        UIAlertController *alertView2 = [UIAlertController alertControllerWithTitle:@"选择被控制的通道" message:@"\n\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];
        UIPickerView *picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 30, alertView.view.frame.size.width-20, alertView.view.frame.size.height)];
        picker.dataSource = self;
        picker.delegate = self;
        [alertView2.view addSubview:picker];
        
        UIAlertAction *yesAction2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                                     {
                                         SomeBtn *theImage = [[SomeBtn alloc]initWithFrame:CGRectMake(300, 300, 40, 40)];
                                         int selectedrow = [picker selectedRowInComponent:0];
                                         theImage.channel = (int)[channelArray[selectedrow] integerValue];
                                         NSLog(@"selected row %d",[picker selectedRowInComponent:0]);
                                         theImage.imageNum = (int)indexPath.row+1;
                                         if([_stateArray[theImage.channel] boolValue])
                                         {
                                             [theImage setState:YES];
                                         }
                                         else
                                         {
                                             [theImage setState:NO];
                                         }
                                         theImage.layer.cornerRadius = 10;
                                         theImage.layer.masksToBounds = YES;
                                         theImage.userInteractionEnabled = YES;
                                         
                                         if(switchButton.on)
                                         {
                                             panpanpan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(draging:)];
                                             [theImage addGestureRecognizer:panpanpan];
                                         }
                                         
                                         UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressed:)];
                                         [theImage addGestureRecognizer:longpress];
                                         
                                         UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchedSomething:)];
                                         [theImage addGestureRecognizer:tap];
                                         [self.view addSubview: theImage];
                                         [channelArray removeObject:[NSString stringWithFormat:@"%d",theImage.channel]];
                                         [self saveTheButton:theImage key:theImage.channel];
                                     }];
        
        UIAlertAction *noAction2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alertView2 addAction:yesAction2];
        [alertView2 addAction:noAction2];
        
        [self presentViewController:alertView2 animated:YES completion:nil];
        
    }];
    
    [alertView addAction:yesAction];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertView addAction:noAction];
    
    [self presentViewController:alertView animated:YES completion:nil];
    
    //为sheet添加一个pickerView
    
    
    
    
}
#pragma mark pickerView datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 20.0;
}
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return channelArray.count;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return channelArray[row];
  //  return [NSString stringWithFormat:@"%ld",row+1];
}
#pragma mark 按钮这个类的存储
-(void)saveTheButton:(SomeBtn *)button key:(int)channel
{
//    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
//
//    [defaults setObject:button forKey:@"1"];
//    
//    [defaults synchronize];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:button];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:[NSString stringWithFormat:@"%d",channel]];
    
}
-(void)removeTheButton:(SomeBtn *)Button
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%d",Button.channel]];
    [Button removeFromSuperview];
    [channelArray addObject:[NSString stringWithFormat:@"%d",Button.channel]];
    NSComparator finderSort = ^(id string1,id string2){
        
        if ([string1 integerValue] > [string2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }else if ([string1 integerValue] < [string2 integerValue]){
            return (NSComparisonResult)NSOrderedAscending;
        }
        else
            return (NSComparisonResult)NSOrderedSame;
    };
    
    channelArray = [[channelArray sortedArrayUsingComparator:finderSort] copy];
}
-(void)readTheButtonWithGesture:(BOOL) deny
{
    
  //  NSLog(@"%i %f",btn.channel,btn.myFramex);
    
    for (int i =1 ; i<=10; i++) {
        NSData *data = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"%d",i]];
        if (data == nil) {
            continue;
        }else{
            [channelArray removeObject:[NSString stringWithFormat:@"%d",i]];
            //  NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
            SomeBtn *btn = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if([_stateArray[i] boolValue])
            {
            [btn setState:YES];
            }
            else
            {
                [btn setState:NO];
            }
            btn.frame = CGRectMake(btn.myFramex, btn.myFramey, 40, 40);
            btn.layer.cornerRadius = 10;
            btn.layer.masksToBounds = YES;
            btn.userInteractionEnabled = YES;
            
            if (deny) {
                panpanpan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(draging:)];
                [btn addGestureRecognizer:panpanpan];
            }
            
            UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressed:)];
            [btn addGestureRecognizer:longpress];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchedSomething:)];
            [btn addGestureRecognizer:tap];
            [self.view addSubview: btn];
            [self.view bringSubviewToFront:btn];
        }
    }
}
-(void)SwitchDataDeal:(NSData *)data
{
    NSLog(@"receive");
    Byte *bytes = (Byte *)[data bytes];
    _stateArray[1]=[NSString stringWithFormat:@"%d",bytes[9]%2];
    _stateArray[2]=[NSString stringWithFormat:@"%d",bytes[9]/2%2];
    _stateArray[3]=[NSString stringWithFormat:@"%d",bytes[9]/4%2];
    _stateArray[4]=[NSString stringWithFormat:@"%d",bytes[9]/8%2];
    _stateArray[5]=[NSString stringWithFormat:@"%d",bytes[9]/16%2];
    _stateArray[6]=[NSString stringWithFormat:@"%d",bytes[9]/32%2];
    _stateArray[7]=[NSString stringWithFormat:@"%d",bytes[9]/64%2];
    _stateArray[8]=[NSString stringWithFormat:@"%d",bytes[9]/128%2];
    _stateArray[9]=[NSString stringWithFormat:@"%d",bytes[8]%2];
    _stateArray[10]=[NSString stringWithFormat:@"%d",bytes[8]/2%2];
    _stateArray[0]=[NSString stringWithFormat:@"%d",bytes[8]/4%2];
    
    [_stateArray writeToFile:[dataPath dataFilePathForRect] atomically:YES];
}
-(void)saveChannel:(int)channel state:(BOOL)on
{
    _stateArray[channel] = on?@"1":@"0";
    [_stateArray writeToFile:[dataPath dataFilePathForRect] atomically:YES];
}
@end
