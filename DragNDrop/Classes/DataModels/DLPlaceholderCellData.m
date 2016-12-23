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

- (instancetype)initWithSelectedIndexOfList:(NSInteger)index
                selectedIndexPathInsideList:(NSIndexPath *)indexPath {
    
    self = [super init];
    
    if (self) {
        
        _selectedIndexOfList = index;
        _selectedIndexPathInsideList = indexPath;
    }
    
    return self;
}

@end
