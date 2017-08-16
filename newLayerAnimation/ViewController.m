//
//  ViewController.m
//  newLayerAnimation
//
//  Created by APPLE on 2017/8/9.
//  Copyright © 2017年 David. All rights reserved.
//

#import "ViewController.h"
#import "QMNumberScrollAnimatedLayer.h"
#import "QMNumberExpandLayer.h"

@interface ViewController ()

@property (nonatomic, weak) QMNumberScrollAnimatedLayer *layer;
@property (nonatomic, strong) QMNumberExpandLayer *expandLayer;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger number;

@property (nonatomic, assign) BOOL testSwitch;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _testSwitch = YES;
    
    if (_testSwitch) {
        
        [self test1];
    } else {
        
        self.expandLayer = [[QMNumberExpandLayer alloc] initWithComboNumber:self.number];
        CGRect temFrame = self.expandLayer.frame;
        self.expandLayer.frame = CGRectMake(200, 300, temFrame.size.width, temFrame.size.height);
        [self.view.layer addSublayer:self.expandLayer];
    }
 
}

- (NSTimer *)timer {
    if (!_timer) {
        __weak typeof(self) weakSelf = self;
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.6 repeats:YES block:^(NSTimer * _Nonnull timer) {
            
        }];
    }
    return _timer;
}


- (void)test1 {
    QMNumberScrollAnimatedLayer *layer = [[QMNumberScrollAnimatedLayer alloc] init];
    layer.backgroundColor = [UIColor redColor].CGColor;
    layer.frame = CGRectMake(100, 50, 100, 16.5); 
    layer.comboNumber = 1314;
    layer.animationDuration = 15;
    [self.view.layer addSublayer:layer];
    self.layer = layer;
}

- (IBAction)buttonDidClick:(id)sender {
    if (_testSwitch) {
        
//        [_layer setValue:[NSNumber numberWithInt:((arc4random() % 10000 + 10))]];
        [_layer startAnimation];
    }
    else {
        
        self.number++;
        [self.expandLayer changedComboNumber:self.number animation:YES];
    }
}

@end


@implementation TestLayer

- (void)drawInContext:(CGContextRef)ctx
{
    //来绘制图层
    //提示：在形变坐标系前，记得保存坐标系，使用后再恢复坐标系。
    CGContextSaveGState(ctx);
    
    CGContextTranslateCTM(ctx, 0.0, self.bounds.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);  
    
    //a.翻转
//    CGContextScaleCTM(ctx, 1.0, -1.0);
//    //b.平移
//    CGContextTranslateCTM(ctx, 0, -self.bounds.size.height);
    
    UIImage *image = [UIImage imageNamed:@"1.jpeg"];
    CGContextDrawImage(ctx, CGRectMake(50, 50, 100, 100), image.CGImage);
    CGContextRestoreGState(ctx);
//    //画青色的园
//    CGContextAddEllipseInRect(ctx, CGRectMake(0, 0, 100, 100));
//    CGContextSetRGBFillColor(ctx, 0.0, 1.0, 1.0, 1.0);
//    CGContextDrawPath(ctx, kCGPathFill);
//    NSLog(@"draw In context");
//    //画蓝色的园
//    CGContextAddEllipseInRect(ctx, CGRectMake(100, 100, 100, 100));
//    CGContextSetRGBFillColor(ctx, 1.0, 0.0, 1.0, 1.0);
//    CGContextDrawPath(ctx, kCGPathFill);
}

@end
