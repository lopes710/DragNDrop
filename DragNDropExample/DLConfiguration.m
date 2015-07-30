//
//  DLDragNDropConfiguration.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 27/07/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLConfiguration.h"

static CGFloat const kRepositionDuration = 0.5;
static CGFloat const kScrollDuration = 0.03;

@interface DLConfiguration ()

@end

@implementation DLConfiguration

- (instancetype)init {

    self = [super init];
    
    if (self) {
    
        _repositionDurationInSeconds = kRepositionDuration;
        _scrollDurationInSeconds     = kScrollDuration;
    }
    
    return self;
}

- (void)setAnimationDurationInSeconds:(CGFloat)animationDurationInSeconds {

    // should I put a maximum here ??
    if (animationDurationInSeconds <= 2.0) {
    
        _repositionDurationInSeconds = animationDurationInSeconds;
        
    } else {
    
        _repositionDurationInSeconds = kRepositionDuration;
        
    }
}


@end
