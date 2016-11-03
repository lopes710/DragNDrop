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

@implementation DLConfiguration

- (instancetype)init {

    self = [super init];
    
    if (self) {
    
        _repositionDurationInSeconds = kRepositionDuration;
        _scrollDurationInSeconds     = kScrollDuration;
        _showEmptyCellOnHovering     = YES;
    }
    
    return self;
}

- (void)setAnimationDurationInSeconds:(CGFloat)animationDurationInSeconds {

    if (animationDurationInSeconds <= 2.0) {
    
        _repositionDurationInSeconds = animationDurationInSeconds;
        
    } else {
    
        _repositionDurationInSeconds = kRepositionDuration;
        
    }
}

- (void)setScrollDurationInSeconds:(CGFloat)scrollDurationInSeconds {

    if (scrollDurationInSeconds <= 0.1) {
        
        _scrollDurationInSeconds = scrollDurationInSeconds;
        
    } else {
        
        _scrollDurationInSeconds = kScrollDuration;
        
    }
}

@end
