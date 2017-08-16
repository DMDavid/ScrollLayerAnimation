//
//  QMNumberScrollAnimatedLayer.m
//  Example
//
//  Created by APPLE on 2017/8/9.
//  Copyright © 2017年 Jonathan Tribouharet. All rights reserved.
//

#define random(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]
#define randomColor random(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

#import "QMNumberScrollAnimatedLayer.h"

@interface QMNumberScrollAnimatedLayer () <CAAnimationDelegate> {
    NSMutableArray *scrollLayers;
//    NSMutableArray *scrollLabels;
    NSMutableDictionary *imageDict;             //资源字典
    NSMutableArray *sourceDatas;                //所以数字数组
    
    NSMutableArray *numberList;                 //数字集合
    NSMutableArray *turnList;                   //所需转的圈数集合
    NSMutableArray *turnAnimationDurations;     //圈数动画时间集合
    NSMutableArray *numberAnimationDurations;   //格数动画时间集合
    CFTimeInterval interval;                    //间隔
}

#define comboNumberkey(key) [NSString stringWithFormat:@"comboKey%ld", key]

@end

@implementation QMNumberScrollAnimatedLayer 

- (instancetype)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    scrollLayers = [NSMutableArray new];
//    scrollLabels = [NSMutableArray new];
}

- (void)startAnimation
{ 
    [self prepareAnimations];
    [self createAnimations];
    
}

- (void)stopAnimation
{
    for(CALayer *layer in scrollLayers){
        [layer removeAnimationForKey:@"JTNumberScrollAnimatedView"];
    }
}

- (void)prepareAnimations
{
    for(CALayer *layer in scrollLayers){
        [layer removeFromSuperlayer];
    }
    
    [scrollLayers removeAllObjects];
//    [scrollLabels removeAllObjects];
    
    [self createSourceDatas];
    [self createScrollLayers];
}

- (void)createSourceDatas {
    imageDict = [NSMutableDictionary dictionary];
    for (int i = 0; i < 10; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"img_Combo_%d", i]];
        NSString *string = comboNumberkey((long)i);
        [imageDict setObject:image forKey:string];
    }
    
    sourceDatas = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10; i++) {
        [sourceDatas addObject:[UIImage imageNamed:[NSString stringWithFormat:@"img_Combo_%d", i]]];
    }
}

- (void)createScrollLayers
{
    CGFloat width = roundf(CGRectGetWidth(self.frame) / numberList.count);
    CGFloat height = CGRectGetHeight(self.frame);
    
    NSString *comboString = [NSString stringWithFormat:@"%ld", self.comboNumber];
    for(NSUInteger i = 0; i < comboString.length; ++i){
        CAScrollLayer *layer = [CAScrollLayer layer];
        layer.frame = CGRectMake(roundf(i * width), 0, width, height);
        [scrollLayers addObject:layer];
        [self addSublayer:layer];
        
        layer.backgroundColor = randomColor.CGColor;
    }
    
    //给每个图层加上数据
    for(NSUInteger i = 0; i < comboString.length; ++i){
        CGFloat height = 0;
        CAScrollLayer *scrollLayer = scrollLayers[i];
        for (int j = 9; j >= 0; j--) {
            
            UIImage *image = sourceDatas[j];
            UIImageView * imageView = [self createImage:image];
            imageView.frame = CGRectMake(0, height, CGRectGetWidth(scrollLayer.frame), CGRectGetHeight(scrollLayer.frame));
            [scrollLayer addSublayer:imageView.layer];
//            [scrollLabels addObject:imageView];
            height = CGRectGetMaxY(imageView.frame); 
        }
    }
}

- (void)createContentForLayer:(CAScrollLayer *)scrollLayer withNumberImage:(UIImage *)numberImage
{
}

- (UIImageView *)createImage:(UIImage *)sender
{
    UIImageView *view = [UIImageView new];
    view.image = sender;
    return view;
}

- (void)createAnimations
{
    for (int i = 0; i < scrollLayers.count; i++) {
        CAScrollLayer *scrollLayer = scrollLayers[i];
        CFTimeInterval duration = [turnAnimationDurations[i] doubleValue];
        NSInteger turn = [turnList[i] integerValue];
        
        CGFloat maxY = [[scrollLayer.sublayers lastObject] frame].origin.y;
        
        //第一段动画
        if (duration == 0) {
            continue;
        }
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.y"];
        animation.duration = duration/turn;
        animation.fromValue = [NSNumber numberWithFloat:-maxY];
        animation.toValue = @0;
        animation.repeatCount = turn;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [scrollLayer addAnimation:animation forKey:@"JTNumberScrollAnimatedView"];
        
        //第二段动画
//        CABasicAnimation *secondAnimation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.y"];
//        secondAnimation.duration = duration;
//        secondAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    }
}



#pragma mark - Get/Setter

- (void)setComboNumber:(NSInteger)comboNumber {
    _comboNumber = comboNumber;
    
    numberList = [[NSMutableArray alloc] init];
    numberList = [self getEachDigitImageWithNumber:comboNumber];
    
    turnList = [[NSMutableArray alloc] init];
    turnList = [self getFiterWithNumber:comboNumber];
}

- (void)setAnimationDuration:(CFTimeInterval)animationDuration {
    _animationDuration = animationDuration;
    
#warning 测试
    interval = 0.01;
    
    turnAnimationDurations = [[NSMutableArray alloc] init];
    numberAnimationDurations = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < numberList.count; i++) {
        //格数
        NSInteger number = [numberList[i] integerValue];
        //圈数(一圈十格)
        NSInteger turn = [turnList[i] integerValue];
        
        //圈数时间 (第一段动画时间)
        CFTimeInterval duration = turn *10 *(self.comboNumber * interval) /number;
        NSLog(@"时间-----%f", duration);
        
        //格数时间 (第二段动画时间)
        CFTimeInterval numberDuration = animationDuration - duration;
        
        [turnAnimationDurations addObject:@(duration)];
        [numberAnimationDurations addObject:@(numberDuration)];
    }
}


#pragma mark - protect mothods

//获取每个位上的数字
- (NSMutableArray *)getEachDigitImageWithNumber:(NSInteger)number {
    NSString *string = [NSString stringWithFormat:@"%ld", number];
    NSMutableArray *appendArray = [[NSMutableArray alloc] init];
    for (int i = 1; i<=[string length]; i++) {
        //截取字符串中的每一个字符
        NSString *s = [string substringWithRange:NSMakeRange(0, i)];
        
        [appendArray addObject:s];
    }
    return appendArray;
}

//获取圈数数组
- (NSMutableArray *)getFiterWithNumber:(NSInteger)number {
    NSString *string = [NSString stringWithFormat:@"%ld", number];
    NSMutableArray *appendArray = [[NSMutableArray alloc] init];
    for (int i = 0; i<[string length]; i++) {
        //截取字符串中的每一个字符
        NSString *s = [string substringWithRange:NSMakeRange(0, i)];
        NSLog(@"Fiter string is %@",s);
        
        [appendArray addObject:s];
    }
    return appendArray;
}


@end
