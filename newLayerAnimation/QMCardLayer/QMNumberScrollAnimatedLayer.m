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
    NSMutableDictionary *imageDict;             //资源字典
    NSMutableArray *sourceDatas;                //所有数字图片数组
    
    NSMutableArray *numberList;                 //每个位数的数字集合
    NSMutableArray *eachCountList;              //格数集合
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
        QMScrollLayer *layer = [QMScrollLayer layer];
        layer.frame = CGRectMake(roundf(i * width), 0, width, height);
        [scrollLayers addObject:layer];
        [self addSublayer:layer];
        
        layer.backgroundColor = randomColor.CGColor;
    }
    
    //给每个图层加上数据
    for(NSUInteger i = 0; i < comboString.length; ++i){
        CGFloat height = 0;
        QMScrollLayer *scrollLayer = scrollLayers[i];
        for (int j = 9; j >= 0; j--) {
            
            UIImage *image = sourceDatas[j];
            UIImageView * imageView = [self createImage:image];
            imageView.frame = CGRectMake(0, height, CGRectGetWidth(scrollLayer.frame), CGRectGetHeight(scrollLayer.frame));
            [scrollLayer addSublayer:imageView.layer];
            height = CGRectGetMaxY(imageView.frame);
        }
    }
}

- (void)createContentForLayer:(QMScrollLayer *)scrollLayer withNumberImage:(UIImage *)numberImage
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
        QMScrollLayer *scrollLayer = scrollLayers[i];
        CFTimeInterval duration = [turnAnimationDurations[i] doubleValue];
        NSInteger turn = [turnList[i] integerValue];
        CGFloat number = [numberList[i] floatValue];
        
        //最大偏移量
        CGFloat maxY = [[scrollLayer.sublayers lastObject] frame].origin.y;
        CGFloat eachLayerHeight = [[scrollLayer.sublayers lastObject] frame].size.height;
        //每格偏移量
        CGFloat eachOffsetY = (maxY + eachLayerHeight)/10;
        
        //第一段动画
        if (duration == 0) {
            //第二段动画
            CABasicAnimation *secondAnimation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.y"];
            secondAnimation.duration = self.animationDuration - duration;
            secondAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            secondAnimation.fromValue = [NSNumber numberWithFloat:-maxY];
            secondAnimation.toValue = @(-(maxY - eachOffsetY*number));
            secondAnimation.removedOnCompletion = NO;
            secondAnimation.fillMode = kCAFillModeForwards;
            [scrollLayer addAnimation:secondAnimation forKey:@"secondAnimation"];
            continue;
        }
        
        //第一段动画
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.y"];
        animation.duration = duration/turn;
        animation.fromValue = [NSNumber numberWithFloat:-maxY];
        animation.toValue = @0;
        animation.repeatCount = turn;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.delegate = self;
        
        scrollLayer.tag = i;
        scrollLayer.number = number;
        scrollLayer.maxY = maxY;
        scrollLayer.eachOffsetY = eachOffsetY;
        scrollLayer.beforeDuration = duration;
        

        NSString *animationName = [NSString stringWithFormat:@"turnAnimation_%d", i];
        [scrollLayer addAnimation:animation forKey:animationName];
        
    }
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    for (QMScrollLayer *layer in scrollLayers) {
        NSString *animationName = [NSString stringWithFormat:@"turnAnimation_%d", layer.tag];
        CAAnimation *animation = [layer animationForKey:animationName];
        
        if (animation == anim) {
            NSLog(@"相同");
            
            CGFloat number = layer.number;
            CGFloat eachOffsetY = layer.eachOffsetY;
            CGFloat maxY = layer.maxY;
            CFTimeInterval duration = layer.beforeDuration;
            
            CABasicAnimation *secondAnimation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.translation.y"];
            secondAnimation.duration = self.animationDuration - duration;
            secondAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            secondAnimation.fromValue = [NSNumber numberWithFloat:-maxY];
            secondAnimation.toValue = @(-(maxY - eachOffsetY*number));
            secondAnimation.removedOnCompletion = NO;
            secondAnimation.fillMode = kCAFillModeForwards;
            [layer addAnimation:secondAnimation forKey:@"secondAnimation"];
            
            NSLog(@"动画-----toValue = %@", secondAnimation.toValue);
            
            break;
        }
    }
    
}



#pragma mark - Get/Setter

- (void)setComboNumber:(NSInteger)comboNumber {
    _comboNumber = comboNumber;
    
    eachCountList = [[NSMutableArray alloc] init];
    eachCountList = [self getEachCountWithNumber:comboNumber];
    
    turnList = [[NSMutableArray alloc] init];
    turnList = [self getFiterWithNumber:comboNumber];
    
    numberList = [[NSMutableArray alloc] init];
    numberList = [self getEachDigitImageWithNumber:comboNumber];
}

- (void)setAnimationDuration:(CFTimeInterval)animationDuration {
    _animationDuration = animationDuration;
    
#warning 测试
    interval = 0.01;
    
    turnAnimationDurations = [[NSMutableArray alloc] init];
    numberAnimationDurations = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < eachCountList.count; i++) {
        //格数
        NSInteger number = [eachCountList[i] integerValue];
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
    for (int i = 0; i<[string length]; i++) {
        //截取字符串中的每一个字符
        NSString *s = [string substringWithRange:NSMakeRange(i, 1)];
        NSLog(@"string is %@",s);
        
        [appendArray addObject:s];
    }
    return appendArray;
}

//获取每个位上的数字
- (NSMutableArray *)getEachCountWithNumber:(NSInteger)number {
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


@implementation QMScrollLayer
@end
