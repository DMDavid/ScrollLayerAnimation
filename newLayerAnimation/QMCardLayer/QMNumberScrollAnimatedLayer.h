//
//  QMNumberScrollAnimatedLayer.h
//  Example
//
//  Created by APPLE on 2017/8/9.
//  Copyright © 2017年 Jonathan Tribouharet. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface QMNumberScrollAnimatedLayer : CALayer

@property (nonatomic, assign) NSInteger comboNumber;
@property (assign, nonatomic) CFTimeInterval animationDuration;

- (void)startAnimation;
- (void)stopAnimation;

@end


@interface QMScrollLayer : CAScrollLayer
@property (nonatomic, assign) int tag;
@property (nonatomic, assign) CGFloat number;
@property (nonatomic, assign) CGFloat eachOffsetY;
@property (nonatomic, assign) CGFloat maxY;
@property (nonatomic, assign) CFTimeInterval beforeDuration;
@end
