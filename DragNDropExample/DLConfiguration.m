//
//  DLDragNDropConfiguration.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 27/07/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLConfiguration.h"

static CGFloat const kAnimationDuration = 0.5;

@interface DLConfiguration ()

@end

@implementation DLConfiguration

- (instancetype)init {

    self = [super init];
    
    if (self) {
    
        _animationDurationInSeconds = kAnimationDuration;
    }
    
    return self;
}

- (void)setAnimationDurationInSeconds:(CGFloat)animationDurationInSeconds {

    // should I put a maximum here ??
    if (animationDurationInSeconds <= 2.0) {
    
        _animationDurationInSeconds = animationDurationInSeconds;
        
    } else {
    
        _animationDurationInSeconds = kAnimationDuration;
        
    }
}


@end
