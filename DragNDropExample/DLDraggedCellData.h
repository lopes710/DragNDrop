//
//  DLSelectedCellData.h
//  DragNDropExample
//
//  Created by Duarte Lopes on 23/07/15.
//  Copyright (c) 2015 Duarte Lopes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DLDraggedCellData : NSObject

- (instancetype)initWithCell:(UIImageView *)imageCell selectedIndexOfList:(NSInteger)index selectedIndexPathInsideList:(NSIndexPath *)indexPath item:(id)item;

@property (nonatomic, strong, readonly) UIImageView *draggedCell;
@property (nonatomic, assign, readonly) NSInteger selectedIndexOfList;
@property (nonatomic, strong, readonly) NSIndexPath *selectedIndexPathInsideList;
@property (nonatomic, strong, readonly) id draggedItem;

@end
