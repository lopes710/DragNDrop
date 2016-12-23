//
//  DLPlaceholderCellData.h
//  DragNDropExample
//
//  Created by Duarte Lopes on 25/07/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DLPlaceholderCellData : NSObject

@property (nonatomic, assign) NSInteger selectedIndexOfList;
@property (nonatomic, strong) NSIndexPath *selectedIndexPathInsideList;

- (instancetype)initWithSelectedIndexOfList:(NSInteger)index
                selectedIndexPathInsideList:(NSIndexPath *)indexPath;
@end
