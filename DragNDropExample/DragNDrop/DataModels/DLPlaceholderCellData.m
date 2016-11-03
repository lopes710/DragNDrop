//
//  DLPlaceholderCellData.m
//  DragNDropExample
//
//  Created by Duarte Lopes on 25/07/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import "DLPlaceholderCellData.h"

@implementation DLPlaceholderCellData

#pragma mark - Lifecycle

// TODO: does it need item param?
- (instancetype)initWithSelectedIndexOfList:(NSInteger)index
                selectedIndexPathInsideList:(NSIndexPath *)indexPath
                                       item:(id)item {
    
    self = [super init];
    
    if (self) {
        
        _selectedIndexOfList = index;
        _selectedIndexPathInsideList = indexPath;
    }
    
    return self;
}

@end
